import argparse
import logging
import sys

import requests
import yaml

logging.basicConfig(
    stream=sys.stdout,
    format="%(asctime)s.%(msecs)03d %(levelname)s %(module)s - %(funcName)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    level=logging.INFO,
)

_HELM_REPOSITORY_CHART_CACHE = {}


def _parse_semantic_version(_version: str):
    version = _version[1:] if _version[0] == "v" else _version

    return ["{:0>5}".format(int(i)) if i.isdigit() else i for i in version.split(".")]


def _get_helm_chart_metadata(repo_name: str, repo_url: str, chart_name):
    global _HELM_REPOSITORY_CHART_CACHE

    try:
        if repo_name in _HELM_REPOSITORY_CHART_CACHE:
            return _HELM_REPOSITORY_CHART_CACHE.get(repo_name)

        logging.info("Loading charts for repoisitory '%s'", repo_name)

        response = requests.get(f"{repo_url}/index.yaml")

        response.raise_for_status()

        index_data = yaml.safe_load(response.text)

        _HELM_REPOSITORY_CHART_CACHE[repo_name] = {}

        for _key, _value in index_data.get("entries").items():
            _HELM_REPOSITORY_CHART_CACHE[repo_name][_key] = sorted(
                _value,
                key=lambda x: _parse_semantic_version(x["version"]),
                reverse=True,
            )[0]

        return _HELM_REPOSITORY_CHART_CACHE[repo_name][chart_name]
    except Exception as e:
        logging.warning("Error getting charts for '%s': %s", repo_name, str(e))


def _update_yaml(yaml_file_path):
    with open(yaml_file_path, "r") as f:
        yaml_file = yaml.safe_load(f)

        helm_chart_versions = yaml_file.get("helm_chart_version", {})

        helm_chart_repository = yaml_file.get("helm_chart_repository", {})

        modified = False

        for full_chart_name, current_version in helm_chart_versions.items():
            repo_name, chart_name = full_chart_name.split("/")
            repo_url = helm_chart_repository.get(repo_name)

            if repo_url:
                metadata = _get_helm_chart_metadata(repo_name, repo_url, chart_name)

                if metadata and "version" in metadata:
                    last_version = metadata["version"]

                    if last_version and _parse_semantic_version(
                        last_version
                    ) > _parse_semantic_version(current_version):
                        logging.info(
                            "Update chart '%s' to version '%s' => '%s'",
                            chart_name,
                            current_version,
                            last_version,
                        )

                        helm_chart_versions[full_chart_name] = last_version

                        modified = True
            else:
                logging.warning("Chart '%s' does not have a repo_url", full_chart_name)

        if modified:
            yaml_file["helm_chart_version"] = helm_chart_versions

            with open(yaml_file_path, "w") as fw:
                yaml.dump(yaml_file, fw)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("yaml_file_path", help="Path to the YAML file")
    args = parser.parse_args()

    logging.info("Updating Helm chart versions for '%s'", args.yaml_file_path)
    _update_yaml(args.yaml_file_path)
    logging.info("Updated Helm chart versions for '%s'", args.yaml_file_path)


if __name__ == "__main__":
    main()
