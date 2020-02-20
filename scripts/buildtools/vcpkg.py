#!/usr/bin/env python3
import argparse
import subprocess
import sys
import pathlib
import os
import shutil
import sysconfig


def git_status_is_clean():
    return subprocess.call(["git", "diff", "--quiet"], shell=False) == 0


def git_revision_hash():
    return (
        subprocess.check_output(["git", "rev-parse", "HEAD"], shell=False)
        .decode("utf-8")
        .rstrip("\r\n")
    )


def vcpkg_root_dir():
    return os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


def _vcpkg_executable_path():
    bin_suffix = ""
    if sysconfig.get_platform().startswith("win"):
        bin_suffix = ".exe"

    vcpkg_path = pathlib.Path(vcpkg_root_dir()) / "bin" / ("vcpkg" + bin_suffix)
    if vcpkg_path.exists():
        return vcpkg_path.as_posix()

    return None


def _create_vcpkg_command(triplet, vcpkg_args):
    vcpkg = _vcpkg_executable_path()
    if not vcpkg:
        bootstrap_vcpkg()
        vcpkg = _vcpkg_executable_path()

    vcpkg_root = os.path.join(os.path.dirname(__file__), "..", "..")

    args = [vcpkg, "--vcpkg-root", vcpkg_root]
    if triplet:
        args += ["--triplet", triplet]
    args += vcpkg_args

    return args


def find_cmake_binary():
    dlenv = os.environ.get("VCPKG_DOWNLOADS")
    if dlenv:
        vcpkg_downloads_dir = pathlib.Path(dlenv) / "tools"
    else:
        vcpkg_downloads_dir = pathlib.Path(vcpkg_root_dir()) / "downloads" / "tools"

    # first find cmake in the vcpkg downloads dir
    for cmake_dir in vcpkg_downloads_dir.glob("cmake*/cmake-*/bin/"):
        cmake = shutil.which("cmake", path=cmake_dir.as_posix())
        if cmake:
            return cmake

    # find cmake on the system
    return shutil.which("cmake")


def bootstrap_vcpkg():
    cmake_bin = find_cmake_binary()
    bootstrap_path = pathlib.Path(vcpkg_root_dir()) / "bootstrap.cmake"
    subprocess.check_output([cmake_bin, "-P", bootstrap_path.as_posix()], shell=False)


def run_vcpkg(triplet, vcpkg_args):
    subprocess.check_call(_create_vcpkg_command(triplet, vcpkg_args))


def run_vcpkg_output(triplet, vcpkg_args):
    return subprocess.check_output(_create_vcpkg_command(triplet, vcpkg_args)).decode(
        "UTF-8"
    )


def cmake_configure(
    source_dir,
    build_dir,
    cmake_args,
    triplet=None,
    toolchain=None,
    generator=None,
    verbose=False,
):
    cmake_bin = find_cmake_binary()
    if not cmake_bin:
        raise RuntimeError("cmake executable could not be found")

    cwd = os.getcwd()
    os.chdir(build_dir)

    args = [cmake_bin]
    # args.append("--trace-expand")
    args.append("-G")
    if generator is not None:
        args.append(generator)
        if generator == "Ninja" or generator == "Unix Makefiles":
            args.append("-DCMAKE_BUILD_TYPE=Release")
    elif triplet == "x64-windows-static-vs2019" or triplet == "x64-windows-vs2019":
        args.append("Visual Studio 16 2019")
        args.extend(["-A", "x64"])
        args.extend(["-T", "v142,host=x64"])
    elif triplet == "x64-windows-static" or triplet == "x64-windows":
        args.append("Visual Studio 15 2017 Win64")
        args.extend(["-T", "v141,host=x64"])
    else:
        args.append("Ninja")
        # do not append build type for msvc builds, otherwise debug libraries are not found (multi-config build)
        args.append("-DCMAKE_BUILD_TYPE=Release")

    if triplet is not None:
        args.append("-DVCPKG_TARGET_TRIPLET={}".format(triplet))

    if toolchain is not None:
        args.append("-DCMAKE_TOOLCHAIN_FILE={}".format(toolchain))

    args.append("-DVCPKG_APPLOCAL_DEPS=OFF")
    args.extend(cmake_args)
    args.append(source_dir)

    print(" ".join(args))
    subprocess.check_call(args)
    os.chdir(cwd)


def cmake_build(build_dir, config=None, target=None):
    cmake_bin = find_cmake_binary()
    if not cmake_bin:
        raise RuntimeError("cmake executable could not be found")

    args = [cmake_bin, "--build", build_dir]
    if config is not None:
        args.extend(["--config", config])

    if target is not None:
        args.extend(["--target", target])
    subprocess.check_call(args)


def vcpkg_install_ports(triplet, ports, clean_after_build=False):
    args = ["install", "--recurse"]
    if clean_after_build:
        args.append("--clean-after-build")

    args += ports
    run_vcpkg(triplet, args)


def vcpkg_upgrade_ports(triplet):
    args = ["upgrade", "--no-dry-run"]
    run_vcpkg(triplet, args)


def get_all_triplets():
    triplets = []
    triplet_dir = os.path.join(os.path.dirname(__file__), "..", "..", "triplets")
    for filename in os.listdir(triplet_dir):
        if filename.endswith(".cmake"):
            triplet_name = os.path.splitext(filename)[0]
            triplet_useable_on_platform = False
            platform = sysconfig.get_platform()
            if "wasm" in triplet_name:
                triplet_useable_on_platform = True
            elif platform.startswith("linux"):
                triplet_useable_on_platform = (
                    "linux" in triplet_name
                    or "mingw" in triplet_name
                    or "musl" in triplet_name
                )
            elif platform.startswith("macosx"):
                triplet_useable_on_platform = (
                    "osx" in triplet_name or "mingw" in triplet_name
                )
            elif platform.startswith("win"):
                triplet_useable_on_platform = "windows" in triplet_name
            elif platform.startswith("mingw"):
                triplet_useable_on_platform = "mingw" in triplet_name

            if triplet_useable_on_platform:
                triplets.append(triplet_name)

    return triplets


def select_ports_file(ports_dir, triplet):
    """Select the best matching ports file for the selected triplet
    Will look for a ports-'triplet'.txt file in the specified directory
    If it is not present the ports in ports_dir/ports.txt will be used as fallback
    """
    port_file_candidates = [
        os.path.join(ports_dir, "ports-{}.txt".format(triplet)),
        os.path.join(ports_dir, "ports.txt"),
    ]

    for candidate in port_file_candidates:
        if os.path.exists(candidate):
            return candidate

    raise RuntimeError("No ports file found in '{}'".format(ports_dir))


def read_ports_from_ports_file(ports_file):
    ports_to_install = []
    with open(ports_file) as f:
        content = f.readlines()
        for line in content:
            line = line.strip()
            if not line.startswith("#"):
                ports_to_install.append(line)

    return ports_to_install


def prompt_for_triplet():
    triplets = get_all_triplets()
    index = 1
    displaymessage = "Select triplet to use:\n"
    for triplet in triplets:
        displaymessage += "{}: {}\n".format(index, triplet)
        index += 1
    displaymessage += "--> "

    try:
        triplet_index = int(input(displaymessage))
        if triplet_index < 1 or triplet_index > len(triplets):
            raise RuntimeError("Invalid triplet index selected")
        return triplets[triplet_index - 1]
    except ValueError:
        raise RuntimeError("Invalid triplet option selected")


def bootstrap_argparser():
    parser = argparse.ArgumentParser(
        description="Bootstrap vcpkg ports.", add_help=False
    )
    parser.add_argument(
        "-t", "--triplet", dest="triplet", metavar="TRIPLET", help="the triplet to use"
    )
    parser.add_argument(
        "-p",
        "--ports-dir",
        dest="ports_dir",
        metavar="PORTS_DIR",
        help="directory containing the ports file descriptions",
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        dest="clean",
        help="clean the vcpkg build directories",
    )
    parser.add_argument(
        "--clean-after-build",
        action="store_true",
        dest="clean_after_build",
        help="clean buildtrees, packages and downloads after building each package",
    )
    parser.add_argument(
        "--parent",
        action="store_true",
        dest="parent",
        help="bootstrap in the parent directory",
    )

    return parser


def bootstrap(ports_dir, triplet=None, additional_ports=[], clean_after_build=False):
    if triplet is None:
        triplet = prompt_for_triplet()

    ports_file = select_ports_file(ports_dir, triplet)
    print("Using ports defined in: {}".format(os.path.abspath(ports_file)))
    ports_to_install = read_ports_from_ports_file(ports_file)
    ports_to_install.extend(additional_ports)

    try:
        vcpkg_upgrade_ports(triplet)
        vcpkg_install_ports(triplet, ports_to_install, clean_after_build)
    except subprocess.CalledProcessError as e:
        raise RuntimeError("Bootstrap failed: {}".format(e))


def build_project(
    project_dir,
    triplet=None,
    cmake_args=[],
    build_dir=None,
    install_dir=None,
    generator=None,
    target=None,
    build_name=None,
    verbose=False,
):
    if triplet is None:
        triplet = prompt_for_triplet()

    if build_name:
        project_build_dir = "{}-{}".format(build_name, triplet)
    else:
        project_build_dir = "{}".format(triplet)

    if not build_dir:
        build_dir = os.path.join(project_dir, "build", project_build_dir)
    os.makedirs(build_dir, exist_ok=True)

    if not install_dir:
        install_dir = build_dir + "-install"
    cmake_args.append("-DCMAKE_INSTALL_PREFIX={}".format(install_dir))

    vcpkg_root = vcpkg_root_dir()
    toolchain_file = os.path.abspath(
        os.path.join(vcpkg_root, "scripts", "buildsystems", "vcpkg.cmake")
    )

    try:
        cmake_configure(
            project_dir,
            build_dir,
            cmake_args,
            triplet,
            toolchain=toolchain_file,
            generator=generator,
            verbose=verbose,
        )
        cmake_build(build_dir, config="Release", target=target)
    except subprocess.CalledProcessError as e:
        raise RuntimeError("Build failed: {}".format(e))


def build_project_release(
    project_dir, triplet=None, cmake_args=[], build_name=None, install_dir=None
):
    if not git_status_is_clean():
        raise RuntimeError("Git status is not clean")

    if build_name:
        build_dir = "{}-{}-dist".format(build_name, triplet)
    else:
        build_dir = "{}-dist".format(triplet)

    build_dir = os.path.join(project_dir, "build", build_dir)

    if os.path.exists(build_dir):
        shutil.rmtree(build_dir, ignore_errors=True)

    git_hash = git_revision_hash()
    cmake_args.append("-DPACKAGE_VERSION_COMMITHASH=" + git_hash)
    build_project(project_dir, triplet, cmake_args, build_dir, install_dir=install_dir)


def vcpkg_list_ports(triplet):
    args = ["list"]
    ports = set()
    for line in run_vcpkg_output(triplet, args).splitlines():
        if line.startswith("No packages are installed"):
            return ports

        name, trip = tuple(line.split()[0].split(":"))
        if triplet is None or trip == triplet:
            if not "[" in name:
                ports.add(name)

    return ports


def clean(triplet):
    packages_dir = os.path.join(vcpkg_root_dir(), "packages")

    if triplet is None:
        shutil.rmtree(os.path.join(vcpkg_root_dir(), "installed"))
        shutil.rmtree(os.path.join(vcpkg_root_dir(), "buildtrees"))
        shutil.rmtree(packages_dir)
        return

    if os.path.exists(packages_dir):
        for directory in os.listdir(os.path.join(vcpkg_root_dir(), "packages")):
            package, package_triplet = tuple(directory.split("_"))
            if package.startswith("."):
                continue
            if package_triplet == triplet:
                shutil.rmtree(os.path.join(vcpkg_root_dir(), "packages", directory))

    ports = vcpkg_list_ports(triplet)
    if len(ports) > 0:
        run_vcpkg(triplet, ["remove", "--recurse"] + list(ports))


def build_argparser():
    parser = argparse.ArgumentParser(
        description="Build the project using vcpkg dependencies.", add_help=False
    )
    parser.add_argument(
        "-t", "--triplet", dest="triplet", metavar="TRIPLET", help="the triplet to use"
    )
    parser.add_argument(
        "-s",
        "--source-dir",
        dest="source_dir",
        metavar="SOURCE_DIR",
        default=".",
        help="directory containing the sources to build",
    )
    parser.add_argument(
        "--parent",
        action="store_true",
        dest="parent",
        help="use bootstrapped dependencies from the parent directory",
    )
    parser.add_argument(
        "--dist",
        dest="build_dist",
        action="store_true",
        help="build a release with proper git commit hash",
    )
    parser.add_argument(
        "--install-prefix",
        dest="install_prefix",
        help="specify the installation prefix",
    )
    parser.add_argument(
        "--verbose", dest="verbose", action="store_true", help="print executed commands"
    )

    return parser


if __name__ == "__main__":
    try:
        parser = argparse.ArgumentParser(
            description="Bootstrap vcpkg ports.", parents=[bootstrap_argparser()]
        )
        args = parser.parse_args()

        bootstrap(
            args.ports_dir, args.triplet, clean_after_build=args.clean_after_build
        )
    except KeyboardInterrupt:
        print("Interrupted")
        sys.exit(-1)
    except RuntimeError as e:
        print(e)
        sys.exit(-1)
