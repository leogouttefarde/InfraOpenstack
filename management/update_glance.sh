#!/bin/bash
# Image creation for users

sudo sed -i 's/"publicize_image": "role:admin"/"publicize_image": ""/' /etc/glance/policy.json

