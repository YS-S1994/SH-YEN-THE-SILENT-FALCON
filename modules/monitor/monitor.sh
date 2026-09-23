#!/usr/bin/env bash

monitor_processes() {
    ps aux 2>/dev/null || ps
}

monitor_memory() {
    system_memory
}

monitor_storage() {
    system_storage
}

monitor_network() {
    network_ports
}

monitor_all() {
    system_info
    system_memory
    system_storage
    network_ports
}
