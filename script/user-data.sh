#!/bin/bash

# ECS config
{
  echo "ECS_CLUSTER=tztf-ecs"
} >> /etc/ecs/ecs.config

start ecs

echo "Done"
