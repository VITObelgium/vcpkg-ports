#!/usr/bin/env python3
import argparse
import subprocess
import sys
import pathlib
import os
import re
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

    vcpkg_path = pathlib.Path(vcpkg_root_dir()) / ("vcpkg" + bin_suffix)
    if vcpkg_path.exists():
        return vcpkg_path.as_posix()

    return None


def _vcpkg_version_check(vcpkg_path):
    output = subprocess.check_output([vcpkg_path, "version"]).decode("utf-8")
    return "2022-06-17" in output


def _args_to_array(args):
    if type(args) == list:
        return args

    if args:
        return args.split(" ")
    else:
        return []


def _create_vcpkg_command(triplet, vcpkg_args):
    vcpkg = _vcpkg_executable_path()
    if not vcpkg or not _vcpkg_version_check(vcpkg):
        bootstrap_vcpkg(triplet)
        vcpkg = _vcpkg_executable_path()

    vcpkg_root = os.path.join(os.path.dirname(__file__), "..", "..")

    args = [vcpkg, "--vcpkg-root", vcpkg_root]
    if triplet:
        args += ["--triplet", triplet]
    args += vcpkg_args

    return args


def find_cmake_binary(binary="cmake"):
    dlenv = os.environ.get("VCPKG_DOWNLOADS")
    if dlenv:
        vcpkg_downloads_dir = pathlib.Path(dlenv) / "tools"
    else:
        vcpkg_downloads_dir = pathlib.Path(vcpkg_root_dir()) / "downloads" / "tools"

    # first find cmake in the vcpkg downloads dir
    for cmake_dir in vcpkg_downloads_dir.glob("cmake*/cmake-*/bin/"):
        cmake = shutil.which(binary, path=cmake_dir.as_posix())
        if cmake:
            return cmake

    # find cmake on the system
    return shutil.which(binary)


def find_ninja_binary():
    dlenv = os.environ.get("VCPKG_DOWNLOADS")
    if dlenv:
        vcpkg_downloads_dir = pathlib.Path(dlenv) / "tools"
    else:
        vcpkg_downloads_dir = pathlib.Path(vcpkg_root_dir()) / "downloads" / "tools"

    # first find ninja in the vcpkg downloads dir
    for ninja_dir in vcpkg_downloads_dir.glob("ninja*/"):
        ninja = shutil.which("ninja", path=ninja_dir.as_posix())
        if ninja:
            return ninja

    # find ninja on the system
    return shutil.which("ninja")


def bootstrap_vcpkg(triplet):
    cmake_bin = find_cmake_binary()
    if not cmake_bin:
        raise RuntimeError("cmake executable could not be found")
    print("Bootstrapping vcpkg")
    bootstrap_path = pathlib.Path(vcpkg_root_dir()) / "bootstrap.cmake"
    vs2019 = "ON" if 'vs2019' in triplet else "OFF"
    cmd = [cmake_bin, f"-DVS2019={vs2019}", "-P", bootstrap_path.as_posix()]
    subprocess.check_output(cmd, shell=False)


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
    generator=None,
    verbose=False,
    build_config="Release",
    install_root=None,
    manifest_dir=None,
):
    cmake_bin = find_cmake_binary()
    if not cmake_bin:
        raise RuntimeError("cmake executable could not be found")

    args = [cmake_bin]
    # args.append("--trace-expand")
    args.append("-G")
    if generator is not None:
        args.append(generator)
        if generator == "Ninja" or generator == "Unix Makefiles":
            args.append(f"-DCMAKE_BUILD_TYPE={build_config}")
    elif triplet == "x64-windows-static-vs2019" or triplet == "x64-windows-vs2019":
        args.append("Visual Studio 16 2019")
        args.extend(["-A", "x64"])
        args.extend(["-T", "v142,host=x64"])
    elif triplet == "x86-windows-static-vs2019" or triplet == "x86-windows-vs2019":
        args.append("Visual Studio 16 2019")
        args.extend(["-A", "Win32"])
        args.extend(["-T", "v142,host=x64"])
    elif triplet == "x64-windows-static-vs2022" or triplet == "x64-windows-vs2022":
        args.append("Visual Studio 17 2022")
        args.extend(["-A", "x64"])
        args.extend(["-T", "v143,host=x64"])
    elif triplet == "x86-windows-static-vs2022" or triplet == "x86-windows-vs2022":
        args.append("Visual Studio 17 2022")
        args.extend(["-A", "Win32"])
        args.extend(["-T", "v143,host=x64"])
    elif triplet == "x64-windows-static" or triplet == "x64-windows":
        args.append("Visual Studio 15 2017 Win64")
        args.extend(["-T", "v141,host=x64"])
    else:
        generator = "Ninja"
        args.append(generator)
        # do not append build type for msvc builds, otherwise debug libraries are not found (multi-config build)
        args.append(f"-DCMAKE_BUILD_TYPE={build_config}")

    if generator == "Ninja":
        ninja_bin = find_ninja_binary()
        if not ninja_bin:
            raise RuntimeError("ninja executable could not be found")
        args.append(f"-DCMAKE_MAKE_PROGRAM={ninja_bin}")

    vcpkg_root = vcpkg_root_dir()
    toolchain = os.path.abspath(
        os.path.join(vcpkg_root, "scripts", "buildsystems", "vcpkg.cmake")
    )
    args.append("-DCMAKE_TOOLCHAIN_FILE={}".format(toolchain))

    if triplet is not None:
        triplet_file = os.path.abspath(
            os.path.join(vcpkg_root, "triplets", f"{triplet}.cmake")
        )

        with open(triplet_file) as f:
            if not "VCPKG_CHAINLOAD_TOOLCHAIN_FILE" in f.read():
                default_toolchain = None
                # no toolchain chainload set in the triplet, set the default
                if "windows" in triplet:
                    default_toolchain = "windows.cmake"
                elif "linux" in triplet:
                    default_toolchain = "linux.cmake"
                elif "osx" in triplet:
                    default_toolchain = "osx.cmake"

                if default_toolchain is not None:
                    chainload_file = os.path.abspath(
                        os.path.join(
                            vcpkg_root, "scripts", "toolchains", default_toolchain
                        )
                    )
                    args.append(f"-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE={chainload_file}")

        args.extend(["-C", triplet_file])
        args.append("-DVCPKG_TARGET_TRIPLET={}".format(triplet))

    args.append("-DVCPKG_APPLOCAL_DEPS=OFF")
    if verbose:
        args.append("-DVCPKG_VERBOSE=ON")
    args.extend(cmake_args)
    args.extend(["-S", source_dir, "-B", build_dir])

    if manifest_dir is not None:
        manifest_path = pathlib.Path(manifest_dir) / "vcpkg.json"
    else:
        manifest_path = pathlib.Path(source_dir) / "vcpkg.json"
    if manifest_path.exists():
        if not install_root:
            install_root = "vcpkg_installed"

        manifest_install_path = pathlib.Path(source_dir) / install_root
        args.append(f"-DVCPKG_INSTALLED_DIR={manifest_install_path.as_posix()}")
        args.append("-DVCPKG_MANIFEST_MODE=OFF")

    print(" ".join(args))
    subprocess.check_call(args)


def cmake_build(build_dir, config=None, targets=[]):
    cmake_bin = find_cmake_binary()
    if not cmake_bin:
        raise RuntimeError("cmake executable could not be found")

    args = [cmake_bin, "--build", build_dir]
    if config is not None:
        args.extend(["--config", config])

    for target in targets:
        args.extend(["--target", target])
    subprocess.check_call(args)


def vcpkg_install_ports(
    triplet,
    ports,
    clean_after_build=False,
    overlay_ports=None,
    overlay_triplets=None,
    build_root=None,
    packages_root=None,
    install_root=None,
):
    args = [
        "install",
        "--recurse",
        "--feature-flags=-manifests",
        "--clean-packages-after-build",
    ]
    if clean_after_build:
        args.append("--clean-after-build")

    if overlay_ports:
        args.append(f"--overlay-ports={overlay_ports}")

    if overlay_triplets:
        args.append(f"--overlay-triplets={overlay_triplets}")

    if build_root:
        args.append(f"--x-buildtrees-root={build_root}")

    if packages_root:
        args.append(f"--x-packages-root={packages_root}")

    if install_root:
        args.append(f"--x-install-root={install_root}")

    if "vs2019" in triplet or "cluster" in triplet or "musl" in triplet:
        args.append(f"--host-triplet={triplet}")

    args += ports

    my_env = os.environ
    my_env["VCPKG_FORCE_DOWNLOADED_BINARIES"] = "ON"

    run_vcpkg(triplet, args)


def vcpkg_install_manifest(
    triplet,
    clean_after_build=False,
    overlay_ports=None,
    overlay_triplets=None,
    build_root=None,
    packages_root=None,
    install_root=None,
    manifest_dir=None
):
    args = ["install"]

    if overlay_ports:
        args.append(f"--overlay-ports={overlay_ports}")

    if overlay_triplets:
        args.append(f"--overlay-triplets={overlay_triplets}")

    if build_root:
        args.append(f"--x-buildtrees-root={build_root}")

    if packages_root:
        args.append(f"--x-packages-root={packages_root}")

    if install_root:
        args.append(f"--x-install-root={install_root}")

    if manifest_dir:
        args.append(f"--x-manifest-root={manifest_dir}")

    if clean_after_build:
        args.append("--clean-after-build")

    if "vs2019" in triplet or "vs2022" in triplet or "cluster" in triplet or "musl" in triplet:
        args.append(f"--host-triplet={triplet}")

    run_vcpkg(triplet, args)


def vcpkg_upgrade_ports(triplet, overlay_ports=None, overlay_triplets=None):
    args = ["upgrade", "--no-dry-run", "--feature-flags=-manifests"]

    if overlay_ports:
        args.append(f"--overlay-ports={overlay_ports}")

    if overlay_triplets:
        args.append(f"--overlay-triplets={overlay_triplets}")

    run_vcpkg(triplet, args)


def get_all_triplets():
    triplets = []
    triplet_dir = os.path.join(os.path.dirname(__file__), "..", "..", "triplets")
    for filename in os.listdir(triplet_dir):
        if filename.endswith(".cmake") and not "toolchain-" in filename:
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


def platform_for_triplet(triplet):
    if "osx" in triplet:
        return "osx"
    if "linux" in triplet:
        return "linux"
    if "mingw" in triplet:
        return "mingw"
    if "windows" in triplet:
        return "windows"

    raise RuntimeError(f"Unepected triplet: {triplet}")


def platform_matches_filter(platform, filter_array):
    for filter in filter_array:
        if filter.startswith("!"):
            if platform != filter[1:]:
                return True
        elif filter == platform:
            return True

    return False


def read_ports_from_ports_file(ports_file, triplet):
    # portname[feature1, feature2](osx|windows)
    # portname[feature1, feature2](!windows)
    regex = r"([a-z0-9\-]+(?:\[\S*\])?)(?:\((\S+)\))?"

    requested_platform = platform_for_triplet(triplet)

    ports_to_install = []
    with open(ports_file) as f:
        content = f.readlines()
        for line in content:
            line = line.strip()
            if not line.startswith("#"):
                match = re.match(regex, line)
                if match:
                    port = match.group(1)
                    filters = match.group(2)
                    if filters:
                        if platform_matches_filter(
                            requested_platform, filters.split("|")
                        ):
                            ports_to_install.append(port)
                    else:
                        ports_to_install.append(port)

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
    parser.add_argument(
        "--build-root",
        dest="build_root",
        help="customize buildtrees directory location",
    )

    return parser


def bootstrap(
    ports_dir,
    triplet=None,
    additional_ports=[],
    clean_after_build=False,
    overlay_ports=None,
    overlay_triplets=None,
    build_root=None,
    packages_root=None,
    install_root=None,
    manifest_dir=None,
):
    if triplet is None:
        triplet = prompt_for_triplet()

    try:
        if manifest_dir:
            manifest_dir = pathlib.Path(manifest_dir)

        if manifest_dir is None:
            manifest_dir = pathlib.Path(ports_dir) / ".." 

        manifest_path = manifest_dir / "vcpkg.json"
        if manifest_path.exists():
            print(f"Bootstrap using manifest: {manifest_path.resolve()}")
            vcpkg_install_manifest(
                triplet,
                clean_after_build,
                overlay_ports,
                overlay_triplets,
                build_root,
                packages_root,
                install_root,
                manifest_dir=manifest_dir
            )
        else:
            # deprecated bootstrap using the ports.txt file
            ports_file = select_ports_file(ports_dir, triplet)
            print(f"Using ports defined in: {os.path.abspath(ports_file)}")
            ports_to_install = read_ports_from_ports_file(ports_file, triplet)
            ports_to_install.extend(additional_ports)
            if len(ports_to_install) == 0:
                return

            vcpkg_upgrade_ports(triplet, overlay_ports, overlay_triplets)
            vcpkg_install_ports(
                triplet,
                ports_to_install,
                clean_after_build,
                overlay_ports,
                overlay_triplets,
                build_root,
                packages_root,
                install_root,
            )
    except subprocess.CalledProcessError as e:
        raise RuntimeError("Bootstrap failed: {}".format(e))


def build_project(
    project_dir,
    triplet=None,
    cmake_args=[],
    build_dir=None,
    install_dir=None,
    generator=None,
    targets=[],
    build_name=None,
    verbose=False,
    run_tests_after_build=False,
    test_arguments=None,
    build_config="Release",
    install_root=None,
    manifest_dir=None,
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

    if install_dir:
        cmake_args.append("-DCMAKE_INSTALL_PREFIX={}".format(install_dir))
    else:
        cmake_args.append(
            "-DCMAKE_INSTALL_PREFIX={}".format(os.path.join(build_dir, "local"))
        )

    try:
        cmake_configure(
            project_dir,
            build_dir,
            cmake_args,
            triplet,
            generator=generator,
            verbose=verbose,
            build_config=build_config,
            install_root=install_root,
            manifest_dir=manifest_dir,
        )
        cmake_build(build_dir, config=build_config, targets=targets)
    except subprocess.CalledProcessError as e:
        raise RuntimeError("Build failed: {}".format(e))

    if run_tests_after_build:
        try:
            run_tests(
                project_dir,
                triplet,
                build_dir,
                build_name,
                config=build_config,
                extra_args=_args_to_array(test_arguments),
            )
        except subprocess.CalledProcessError as e:
            raise RuntimeError("Unit tests failed: {}".format(e))


def build_project_release(
    project_dir,
    triplet=None,
    cmake_args=[],
    build_name=None,
    install_dir=None,
    targets=[],
    run_tests_after_build=False,
    test_arguments=None,
    build_config="Release",
    install_root=None,
    manifest_dir=None,
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
    build_project(
        project_dir,
        triplet,
        cmake_args,
        build_dir,
        targets=targets,
        install_dir=install_dir,
        install_root=install_root,
        manifest_dir=manifest_dir,
    )

    if run_tests_after_build:
        try:
            run_tests(
                project_dir,
                triplet,
                build_dir,
                build_name,
                config=build_config,
                extra_args=_args_to_array(test_arguments),
            )
        except subprocess.CalledProcessError as e:
            raise RuntimeError("Unit tests failed: {}".format(e))


def run_tests(
    project_dir,
    triplet=None,
    build_dir=None,
    build_name=None,
    config=None,
    extra_args=[],
):
    if triplet is None:
        triplet = prompt_for_triplet()

    if build_name:
        project_build_dir = "{}-{}".format(build_name, triplet)
    else:
        project_build_dir = "{}".format(triplet)

    if not build_dir:
        build_dir = os.path.join(project_dir, "build", project_build_dir)

    ctest_bin = find_cmake_binary(binary="ctest")
    if not ctest_bin:
        raise RuntimeError("ctest executable could not be found")

    cwd = os.getcwd()
    os.chdir(build_dir)
    args = [ctest_bin, "--output-on-failure"]

    if config is not None:
        args.extend(["-C", config])

    args.extend(extra_args)

    print(" ".join(args))
    subprocess.check_call(args)
    os.chdir(cwd)


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
    parser.add_argument(
        "--run-tests",
        dest="run_tests",
        action="store_true",
        help="run the tests after build",
    )
    parser.add_argument(
        "--test-arguments",
        dest="test_args",
        help="additonal arguments to pass to ctest",
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
