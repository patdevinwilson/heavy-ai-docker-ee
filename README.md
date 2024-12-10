# heavy-ai-docker-ee

# Docker Compose Configuration for HeavyAI Service

This `docker-compose.yml` file is designed to run the **HeavyAI** application with GPU acceleration using NVIDIA GPUs. Below is a detailed breakdown of the configuration and usage instructions.

---

## Configuration Overview

### **Services**
#### **heavyai**
This section defines the **HeavyAI** service:

1. **`image`**  
   - **`heavyai/heavyai-ee-cuda:latest`**: Specifies the Docker image to use. The `latest` tag ensures the container runs the most recent version of the HeavyAI Enterprise Edition with CUDA support.

2. **`restart`**  
   - **`always`**: Ensures the container automatically restarts if it crashes or is stopped. Useful for production environments.

3. **`volumes`**  
   - **`/var/lib/heavyai:/var/lib/heavyai`**:  
     Mounts a directory on the host (`/var/lib/heavyai`) to the container (`/var/lib/heavyai`) to store persistent data such as database files.  
     - This ensures that the data is not lost when the container is stopped or removed.

4. **`ports`**  
   - **`6273-6278:6273-6278`**:  
     Maps a range of ports (6273 to 6278) on the host to the same ports on the container. These ports are used by HeavyAI for different services:  
     - **6273**: HeavyAI Server  
     - **6274**: SQL Client  
     - **6275**: HTTP Server  
     - **6276**: WebSocket Server  
     - **6277**: Thrift Protocol  
     - **6278**: Additional services

5. **`deploy`**  
   - This section provides deployment-specific settings, particularly for GPU acceleration:  
     - **`resources`**: Specifies hardware resource reservations.  
       - **`devices`**: Allocates specific devices (GPUs in this case) to the container.  
         - **`driver: nvidia`**: Indicates the use of the NVIDIA driver for GPU support.  
         - **`count: all`**: Allocates all available GPUs to the container.  
         - **`capabilities: [gpu]`**: Ensures the container can access GPU resources.

---

## Prerequisites
To use this configuration, ensure the following:

1. **NVIDIA Container Toolkit**: Install this on your host system to enable GPU acceleration in Docker containers. Follow the official [NVIDIA setup guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) if needed.

2. **Host Directory**: Create the `/var/lib/heavyai` directory on the host to store persistent data.

---

## Usage Instructions

1. Save the configuration to a file named `docker-compose.yml`.

2. Run the following command to start the service:
   ```bash
   docker-compose up -d
   ```

3. Verify that the container is running:
   ```bash
   docker ps
   ```

4. Access the HeavyAI services using the appropriate ports:
   - Example: `http://<host-ip>:6275` for the HTTP server.

---

### Scaling
This setup is designed for single-instance use. If deploying in a swarm or Kubernetes, additional configuration may be required.

---

## References
- [HEAVY.AI Installation using Docker on Ubuntu](https://docs.heavy.ai/installation-and-configuration/installation/install-docker/docker-enterprise-edition-gpu)
- [Install NVIDIA Drivers and Vulkan on Ubuntu](https://docs.heavy.ai/installation-and-configuration/installation/installing-on-ubuntu/install-nvidia-drivers-and-vulkan-on-ubuntu))
- [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)
- [Docker Compose File Reference](https://docs.docker.com/compose/compose-file/)

---

This documentation provides a detailed guide for deploying HeavyAI with GPU support using Docker Compose.

