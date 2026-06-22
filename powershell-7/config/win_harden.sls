# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as powershell_7 with context %}
{%- set pkg_map = powershell_7.get('pkg') or {} %}

# Standardize path environments to keep lines safely under 80 columns
{%- set base_root = pkg_map.get('install_root') |
        default('C:/Program Files/PowerShell/7', true) %}
{%- set env_reg = 'HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\' ~
        'Control\\Session Manager\\Environment' %}

Configure Directory Access Control List For Administrators:
  win_dacl.present:
    - acetype: allow
    - name: '{{ base_root }}'
    - objectType: directory
    - permission: fullcontrol
    - propagation: 'FOLDER&SUBFOLDERS&FILES'
    - user: Administrators

Configure Directory Access Control List For System:
  win_dacl.present:
    - acetype: allow
    - name: '{{ base_root }}'
    - objectType: directory
    - permission: fullcontrol
    - propagation: 'FOLDER&SUBFOLDERS&FILES'
    - user: SYSTEM

Configure Directory Access Control List For Users:
  win_dacl.present:
    - acetype: allow
    - name: '{{ base_root }}'
    - objectType: directory
    - permission: read
    - propagation: 'FOLDER&SUBFOLDERS&FILES'
    - user: Users

Configure System Execution Policy And Logging:
  file.managed:
    - contents: |
        {
          "LogChannels": "Operational",
          "LogLevel": "Normal",
          "Microsoft.PowerShell:ExecutionPolicy": "RemoteSigned"
        }
    - makedirs: True
    - name: '{{ base_root }}/powershell.config.json'

Disable Dotnet Cli Telemetry Tracking:
  reg.present:
    - name: '{{ env_reg }}'
    - vdata: '1'
    - vname: 'DOTNET_CLI_TELEMETRY_OPTOUT'
    - vtype: 'REG_SZ'

Disable Powershell Core Telemetry Tracking:
  reg.present:
    - name: '{{ env_reg }}'
    - vdata: '1'
    - vname: 'POWERSHELL_TELEMETRY_OPTOUT'
    - vtype: 'REG_SZ'
