#!/usr/bin/env bash
#
# Given a list of PostgreSQL versions (defined as directories in the root
# folder of the project), this script generates a JSON object that will be used
# inside the Github workflows as a strategy to create a matrix of jobs to run.
# The JSON object contains, for each PostgreSQL version, the tags of the
# container image to be built.
#
set -eu

# Define an optional aliases for some major versions
declare -A aliases=(
	[15]='latest'
)

GITHUB_ACTIONS=${GITHUB_ACTIONS:-false}

cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}/..")")"
BASE_DIRECTORY="$(pwd)"


# Retrieve the PostgreSQL versions for PostGIS
cd ${BASE_DIRECTORY}/PostGIS
for version in */; do
	[[ $version == src/ ]] && continue
	postgis_versions+=("$version")
done
postgis_versions=("${postgis_versions[@]%/}")

# Sort the version numbers with highest first
mapfile -t postgis_versions < <(IFS=$'\n'; sort -rV <<< "${postgis_versions[*]}")

# prints "$2$1$3$1...$N"
join() {
	local sep="$1"
	shift
	local out
	printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

entries=()
for version in "${postgis_versions[@]}"; do

	# Read versions from the definition file
	versionFile="${version}/.versions.json"
	postgisVersion=$(jq -r '.POSTGIS_IMAGE_VERSION | split("-") | .[1]' "${versionFile}")
	releaseVersion=$(jq -r '.IMAGE_RELEASE_VERSION' "${versionFile}")

	# Initial aliases are:
	# "major version" (of postgres)
	# "optional alias"
	# "major version - postgis version" ("postgis version": "$postgisMajorVersion.$postgisMinorVersion")
	# "major version - postgis version - release version"
	# i.e. "14", "latest", "14-3.2", "14-3.2-1"
	versionAliases=(
			"${version}"
			${aliases[$version]:+"${aliases[$version]}"}
			"${version}-${postgisVersion}"
			"${version}-${postgisVersion}-${releaseVersion}"
		)

	# Support platform for container images
	platforms="linux/amd64"

	# Build the json entry
	entries+=(
		"{\"name\": \"PostGIS ${version}-${postgisVersion}\", \"platforms\": \"$platforms\", \"dir\": \"PostGIS/$version\", \"file\": \"PostGIS/$version/Dockerfile\", \"version\": \"$version\", \"tags\": [\"$(join "\", \"" "${versionAliases[@]}")\"]}"
	)
done

# Build the strategy as a JSON object
strategy="{\"fail-fast\": false, \"matrix\": {\"include\": [$(join ', ' "${entries[@]}")]}}"
jq -C . <<<"$strategy" # sanity check / debugging aid

if [[ "$GITHUB_ACTIONS" == "true" ]]; then
	echo "strategy=$(jq -c . <<<"$strategy")" >> $GITHUB_OUTPUT
fi
