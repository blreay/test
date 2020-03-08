#!/bin/bash

echo "============= order: t1.cpp t2.cpp ========"
g++ main.cpp t.cpp t1.cpp t2.cpp -o inline12
./inline12

echo "============= order: t2.cpp t1.cpp ========"
g++ main.cpp t.cpp t2.cpp t1.cpp -o inline21
./inline21
