#!/usr/bin/env bats

load test_helper

@test "host info esx" {
  run govc host.info
  assert_success
  grep -q Manufacturer: <<<$output

  run govc host.info -host enoent
  assert_failure "govc: host 'enoent' not found"

  for opt in dns ip ipath uuid
  do
    run govc host.info "-host.$opt" enoent
    assert_failure "govc: no such host"
  done

  # avoid hardcoding the esxbox hostname
  local name=$(govc ls '/*/host/*' | grep -v Resources)

  run govc host.info -host $name
  assert_success
  grep -q Manufacturer: <<<$output

  run govc host.info -host ${name##*/}
  assert_success
  grep -q Manufacturer: <<<$output

  run govc host.info -host.ipath $name
  assert_success

  run govc host.info -host.dns $(basename $(dirname $name))
  assert_success

  uuid=$(govc host.info -json | jq -r .HostSystems[].Hardware.SystemInfo.Uuid)
  run govc host.info -host.uuid $uuid
  assert_success
}

@test "host info vc" {
  vcsim_env

  run govc host.info
  assert_success
  grep -q Manufacturer: <<<$output

  run govc host.info -host enoent
  assert_failure "govc: host 'enoent' not found"

  for opt in dns ip ipath uuid
  do
    run govc host.info "-host.$opt" enoent
    assert_failure "govc: no such host"
  done

  local name=$GOVC_HOST

  unset GOVC_HOST
  run govc host.info
  assert_failure "govc: please specify a host"

  run govc host.info -host $name
  assert_success
  grep -q Manufacturer: <<<$output

  run govc host.info -host.ipath $name
  assert_success

  run govc host.info -host.dns $(basename $name)
  assert_success

  uuid=$(govc host.info -host $name -json | jq -r .HostSystems[].Hardware.SystemInfo.Uuid)
  run govc host.info -host.uuid $uuid
  assert_success
}

@test "host.vnic.info" {
  run govc host.vnic.info
  assert_success
}

@test "host.vswitch.info" {
  run govc host.vswitch.info
  assert_success

  run govc host.vswitch.info -json
  assert_success
}

@test "host.portgroup.info" {
  run govc host.portgroup.info
  assert_success

  run govc host.portgroup.info -json
  assert_success
}

@test "host.options" {
    run govc host.option.ls Config.HostAgent.plugins.solo.enableMob
    assert_success

    run govc host.option.ls Config.HostAgent.plugins.
    assert_success

    run govc host.option.ls -json Config.HostAgent.plugins.
    assert_success

    run govc host.option.ls Config.HostAgent.plugins.solo.ENOENT
    assert_failure
}

@test "host.service" {
    run govc host.service.ls
    assert_success

    run govc host.service.ls -json
    assert_success

    run govc host.service status TSM-SSH
    assert_success
}
