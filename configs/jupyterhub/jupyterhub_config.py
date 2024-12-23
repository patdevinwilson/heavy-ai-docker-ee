import os

c = get_config()

# JupyterHub configuration
c.JupyterHub.base_url = '/jupyter'
c.JupyterHub.hub_ip = '0.0.0.0'

# Spawner configuration
c.JupyterHub.spawner_class = "dockerspawner.DockerSpawner"
c.DockerSpawner.image = os.environ["DOCKER_NOTEBOOK_IMAGE"]
c.DockerSpawner.network_name = os.environ["DOCKER_NETWORK_NAME"]
c.DockerSpawner.notebook_dir = os.environ.get("DOCKER_NOTEBOOK_DIR", "/home/jovyan/work")

# Volume mounts
c.DockerSpawner.volumes = {
    "jupyterhub-user-{username}": notebook_dir,
    "/var/lib/heavyai": "/var/lib/heavyai"
}

# Container configuration
c.DockerSpawner.remove = True
c.DockerSpawner.debug = True
c.DockerSpawner.extra_create_kwargs = {'user': 'root'}
c.DockerSpawner.environment = {
    'GRANT_SUDO': '1',
    'UID': '0',
}

# URL routing
c.Spawner.default_url = '/lab'
c.Spawner.args = ['--NotebookApp.allow_origin=*']

# Authentication (using dummy auth for development)
c.JupyterHub.authenticator_class = "dummyauthenticator.DummyAuthenticator"

# Data persistence
c.JupyterHub.cookie_secret_file = "/data/jupyterhub_cookie_secret"
c.JupyterHub.db_url = "sqlite:////data/jupyterhub.sqlite"