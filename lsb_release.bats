#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

LSB_RELEASE="$BATS_TEST_DIRNAME/lsb_release"

assert_equal () {
	[ "$1" = "$2" ] && return 0

	echo "expected '$2', got '$1'" >&2
	return 1
}

assert_equal_ws () {
	local s1=$(echo "$1" | sed -E -e '/\s+/ /')
	local s2=$(echo "$2" | sed -E -e '/\s+/ /')

	[ "$s1" = "$s2" ] && return 0

	echo "expected '$s2', got '$s1'" >&2
	return 1
}

assert_equal_fields () {
	local fields_got=$(echo "$1" | cut -f2) ; shift
	oIFS="$IFS" ; IFS="$(printf '\n ')" ; local fields_expected="$*" ; IFS="$oIFS"

	assert_equal "$fields_got" "$fields_expected"
}

assert_equal_fields_ws () {
	local fields_got=$(echo "$1" | cut -f2) ; shift
	oIFS="$IFS" ; IFS="$(printf '\n ')" ; local fields_expected="$*" ; IFS="$oIFS"

	assert_equal_ws "$fields_got" "$fields_expected"
}

skip_if_no_unicode () {
	if [ "$(echo 'åβ' | cut -c1)" != "β" ]; then
		skip "\`cut\` and \`tr\` are not yet Unicode-aware"
	fi
}

@test "No output without options" {
	export LSB_OS_RELEASE="$BATS_TEST_TMPDIR/os-release"

	echo "$OS_RELEASE_UBUNTU_2204" > "$LSB_OS_RELEASE"

        run $LSB_RELEASE

        assert_equal "$status" "0"
        assert_equal "$output" ""
}

@test "Fields are read from os-release" {
	export LSB_OS_RELEASE="$BATS_TEST_TMPDIR/os-release"

	echo "$OS_RELEASE_UBUNTU_2204" > "$LSB_OS_RELEASE"

        run $LSB_RELEASE -a

        assert_equal "$status" "0"
        assert_equal_fields "$output" "Ubuntu" "Ubuntu 20.04.4 LTS" "20.04" "focal"
}

@test "Fields are reported as n/a if missing" {
	export LSB_OS_RELEASE="$BATS_TEST_TMPDIR/os-release"

	echo "$OS_RELEASE_DEBIAN_SID" > "$LSB_OS_RELEASE"

        run $LSB_RELEASE -a

        assert_equal "$status" "0"
        assert_equal_fields "$output" "Debian" "Debian GNU/Linux bookworm/sid" "n/a" "n/a"
}

@test "All fields are reported as n/a if missing" {
	export LSB_OS_RELEASE="$BATS_TEST_TMPDIR/os-release"

	echo "" > "$LSB_OS_RELEASE"

        run $LSB_RELEASE -a

        assert_equal "$status" "0"
        assert_equal_fields "$output" "n/a" "n/a" "n/a" "n/a"
}

@test "Only ID is shown with -i" {
	export LSB_OS_RELEASE="$BATS_TEST_TMPDIR/os-release"

	echo "$OS_RELEASE_UBUNTU_2204" > "$LSB_OS_RELEASE"

        run $LSB_RELEASE -i

        assert_equal "$status" "0"
        assert_equal_ws "$output" "Distributor ID: Ubuntu"
}

@test "Only Description is shown with -d" {
	export LSB_OS_RELEASE="$BATS_TEST_TMPDIR/os-release"

	echo "$OS_RELEASE_UBUNTU_2204" > "$LSB_OS_RELEASE"

        run $LSB_RELEASE -d

        assert_equal "$status" "0"
        assert_equal_ws "$output" "Description: Ubuntu 20.04.4 LTS"
}

@test "Only Release is shown with -r" {
	export LSB_OS_RELEASE="$BATS_TEST_TMPDIR/os-release"

	echo "$OS_RELEASE_UBUNTU_2204" > "$LSB_OS_RELEASE"

        run $LSB_RELEASE -r

        assert_equal "$status" "0"
        assert_equal_ws "$output" "Release: 20.04"
}

@test "Only Codename is shown with -c" {
	export LSB_OS_RELEASE="$BATS_TEST_TMPDIR/os-release"

	echo "$OS_RELEASE_UBUNTU_2204" > "$LSB_OS_RELEASE"

        run $LSB_RELEASE -c

        assert_equal "$status" "0"
        assert_equal_ws "$output" "Codename: focal"
}

@test "Multiple fields are showns when multiple options are passed" {
	export LSB_OS_RELEASE="$BATS_TEST_TMPDIR/os-release"

	echo "$OS_RELEASE_UBUNTU_2204" > "$LSB_OS_RELEASE"

        run $LSB_RELEASE -c -i

        assert_equal "$status" "0"
        assert_equal_fields_ws "$output" "Distributor ID: Ubuntu" "Codename: focal"
}

@test "Field names are not shown when --short is passed" {
	export LSB_OS_RELEASE="$BATS_TEST_TMPDIR/os-release"

	echo "$OS_RELEASE_UBUNTU_2204" > "$LSB_OS_RELEASE"

        run $LSB_RELEASE -c -i --short

        assert_equal "$status" "0"
        assert_equal_fields "$output" "Ubuntu" "focal"
}

@test "Name is preferred to ID if only different in capitalization" {
	export LSB_OS_RELEASE="$BATS_TEST_TMPDIR/os-release"

	cat > "$LSB_OS_RELEASE" <<EOF
ID=linux
NAME=LiNuX
EOF

        run $LSB_RELEASE -i

        assert_equal "$status" "0"
        assert_equal_fields "$output" "LiNuX"
}

@test "Non-ASCII data in ID is correctly handled" {
	skip_if_no_unicode

	export LSB_OS_RELEASE="$BATS_TEST_TMPDIR/os-release"

	echo "$OS_RELEASE_UNICODE" > "$LSB_OS_RELEASE"

        run $LSB_RELEASE -i --short

        assert_equal "$status" "0"
        assert_equal_fields "$output" "Đεбıå№"
}

@test "Non-ASCII data in ID/NAME is correctly handled" {
	skip_if_no_unicode

	export LSB_OS_RELEASE="$BATS_TEST_TMPDIR/os-release"

	echo "$OS_RELEASE_UNICODE" > "$LSB_OS_RELEASE"
	echo 'NAME="đεБIå№"' >> "$LSB_OS_RELEASE"

        run $LSB_RELEASE -i --short

        assert_equal "$status" "0"
        assert_equal_fields "$output" "đεБIå№"
}

# Fixtures

OS_RELEASE_DEBIAN_SID=$(cat <<EOD
PRETTY_NAME="Debian GNU/Linux bookworm/sid"
NAME="Debian GNU/Linux"
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
EOD
)

OS_RELEASE_UBUNTU_2204=$(cat <<EOD
NAME="Ubuntu"
VERSION="20.04.4 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.4 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
EOD
)

OS_RELEASE_UNICODE=$(cat <<EOD
ID="đεбıå№"
PRETTY_NAME="डेबियन bookwork/sid"
EOD
)
