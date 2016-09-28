How to deploy OpenStack app-catalog with ansible
################################################

Assume we have two nodes: command center (e.g. your laptop) and target. Target
ip address is *192.168.10.10*.

SSH
===

Ansible using ssh, so target node should be accessible via ssh without password. Generate ssh keypair on command node if necessary::

    $ ssh-keygen

*Good news: ssh-agent is supported by ansible*

Put your public key to the target if necessary::

    $ ssh-copy-id user@192.168.10.10

*use proper address of target*

The target
==========

It is important to be able to ssh and sudo on target node without significant
delays. Check your DNS settings and /etc/hosts if necessary. Use 'manage_etc_hosts'
cloud-init setting if target is VM in OpenStack cloud, or check /etc/hosts manually.
This file should contain own hostname::

    127.0.0.1 localhost
    127.0.1.1 target-hostname.example.net

*second line is important*

Also python should be installed on target::

    $ sudo apt-get install python

The command center
==================

Install ansible::

    $ sudo apt-get install ansible

*Replace apt-get with yum/dnf/emerge etc if necessary*

Edit /etc/ansible/hosts::

    [target]
    192.168.10.10 # here shold be address of target node

Ensure target is visible for ansible::

    $ ansible -m ping target -u ubuntu

Output should look like this::

    192.168.10.10 | SUCCESS => {
        "changed": false, 
        "ping": "pong"
    }

Assume we want to keep all ansible files in /store/ansible.

Clone this repository::

    $ mkdir -p /store/ansible/
    $ cd /store/ansible/
    $ git clone https://github.com/redixin/ansible-appcatalog.git

Next we should tell ansible roles search path. Edit /etc/ansible/ansible.cfg and change one line in [defaults] section::

    [defaults]
    roles_path = /etc/ansible/roles:/store/ansible/ansible-appcatalog/roles

Now copy/edit examples/full.yml::

    ---
    - hosts: target
      remote_user: ubuntu
      become: true
      vars:
        glare_pip: git+git://git.openstack.org/openstack/glare.git#egg=glare
        catalog_pip: git+git://github.com/redixin/app-catalog.git@devel#egg=openstack_catalog
        catalog_debug: "True"
        with_app_catalog: true
        glare_nginx_port: 9494
        catalog_nginx_port: 80
        glare_user: www-data
        catalog_user: www-data
        glare_deploy_with: uwsgi
        catalog_deploy_with: uwsgi
        glare_uwsgi_socket: /tmp/glare.sock
        catalog_uwsgi_socket: /tmp/catalog.sock
        catalog_domain: 192.168.10.10
        catalog_protocol: http
        glare_protocol: http
        glare_domain: 192.168.10.10:9494
      roles:
        - nginx
        - glare
        - openstack_catalog

And finally deploy everything::

    $ ansible-playbook examples/full.yml

After that OpenStack App Catalog will be available by url: http://192.168.10.10
