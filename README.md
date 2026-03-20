# llama.cpp Docker ROCm Setup for RX 6700 XT

This repository builds and runs `llama.cpp` inside Docker with ROCm enabled for an AMD Radeon RX 6700 XT (`gfx1030`).

The current compose configuration starts `llama-server` with a Qwen 3.5 GGUF model and matching multimodal projector mounted from the local `models/` directory.

## Repository Layout

- `Dockerfile`: Builds `llama.cpp` from source in a ROCm 7.0 Ubuntu 24.04 image.
- `docker-compose.yml`: Runs `llama-server` with the required GPU device mappings and server arguments.
- `models/`: Local GGUF model storage mounted into the container as `/data`.

## Requirements

- Docker with Compose support
- AMD GPU with ROCm-compatible drivers
- Access to `/dev/kfd` and `/dev/dri`
- Model files present in `models/`

## Build and Run

Build the image:

```bash
docker compose build
```

Start the server:

```bash
docker compose up -d
```

Follow logs:

```bash
docker compose logs -f
```

Stop the server:

```bash
docker compose down
```

## Default Runtime Configuration

The container exposes `llama-server` on port `11534` on the host and forwards it to port `8080` in the container.

The current startup command uses:

- Model: `/data/qwen35_35b_3k.gguf`
- MMProj: `/data/mmproj35b.gguf`
- Context length: `131072`
- Parallel requests: `4`
- Flash attention: enabled
- K/V cache quantization: `q8_0`

If you want to switch models or tune performance, edit the `command:` section in `docker-compose.yml`.

## ROCm Notes

The build and runtime configuration are pinned to the RX 6700 XT target:

- `LLAMACPP_ROCM_ARCH=gfx1030`
- `HSA_OVERRIDE_GFX_VERSION=10.3.0`
- `HIP_VISIBLE_DEVICES=0`

If you are using a different AMD GPU, update those values in both the Docker build args and runtime environment.
