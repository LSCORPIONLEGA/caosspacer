#!/bin/sh
# Compila el motor en Linux/Mac y corre las pruebas (requiere g++, python3, numpy y scipy).
cd "$(dirname "$0")"
g++ -O2 -std=c++17 -shared -fPIC dsp/ts_api.cpp -o /tmp/libcaosspacer.so && g++ -O2 -std=c++17 dsp/ts_cli.cpp -o /tmp/ts_cli && python3 tests/test_dsp.py /tmp/libcaosspacer.so && python3 tests/test_cli.py
