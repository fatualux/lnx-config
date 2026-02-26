#!/usr/bin/env bats

@test "simple metadata test" {
    cd /root/Debian/lnx-config
    source src/install.sh
    
    run create_metadata_header "test" "1"
    [[ "$output" =~ "Auto-generated" ]]
}
