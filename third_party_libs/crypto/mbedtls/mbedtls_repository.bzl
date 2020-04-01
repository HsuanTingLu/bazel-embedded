VERSIONS = {
    "mbedtls-2.16.5": {
        "commit": "0fce215851cc069c5b5def12fcc18725055fa6cf",
        "sha256": "65b4c6cec83e048fd1c675e9a29a394ea30ad0371d37b5742453f74084e7b04d",
    },
}

def _mbedtls_repository_impl(rctx):
    REPOSITORY_NAME = "mbedtls"
    BASE_URL = "https://github.com/ARMmbed/" + REPOSITORY_NAME + "/archive/"

    version_info = VERSIONS[rctx.attr.version]
    rctx.download_and_extract(
        url = BASE_URL + version_info["commit"] + ".zip",
        stripPrefix = REPOSITORY_NAME + "-" + version_info["commit"],
        sha256 = version_info["sha256"],
    )
    rctx.symlink(Label("//third_party_libs/crypto/mbed_tls:mbedtls_defs.bzl"), "mbedtls_defs.bzl")
    target_template = """
mbedtls_project(
    name = "{name}",
    config = "{config}",
)
"""
    targets = [target_template.format(config = config, name = name) for name, config in rctx.attr.project_configs.items()]
    targets_str = "\n".join(targets)
    rctx.file("BUILD", """
package(default_visibility = ["//visibility:public"])
load(":mbedtls_defs.bzl","mbedtls_project")
""" + targets_str + startup_targets_str)

mbedtls_repository_simple = repository_rule(
    implementation = _stm32h7xx_repository_impl,
    attrs = {
        "version": attr.string(
            doc = "Release version of repository",
            default = "mbedtls-2.16.5",
            values = VERSIONS.keys(),
        ),
        "project_configs": attr.string_dict(
            doc = "The key as the named prefix for this project and the value as the Label for your projects config cc_library",
            mandatory = True,
        ),
    },
)

def mbedtls_repository(project_configs, version = "mbedtls-2.16.5"):
    mbedtls_repository_simple(name = "com_mbedtls", project_configs = project_configs, version = version)