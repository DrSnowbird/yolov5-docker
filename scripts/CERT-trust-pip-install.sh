#!/bin/bash -x
  
############################################
#### ---- PIP trust configuration: ---- ####
############################################
#### ref: https://pip.pypa.io/en/stable/topics/configuration/
#### ref: https://stackoverflow.com/questions/25981703/pip-install-fails-with-connection-error-ssl-certificate-verify-failed-certi
####
function setup_pip_conf_trust_cert() {
# ---- PIP config file/location: ----
# (global): /etc/pip.conf
# (user/docker): $HOME/.config/pip/pip.conf
# (venv): $VIRTUAL_ENV/pip.conf
#
mkdir -p $HOME/.config/pip
cat << EOF > $HOME/.config/pip/pip.conf
[global]
trusted-host = pypi.python.org
               pypi.org
               files.pythonhosted.org
EOF

#cp /etc/pip.conf /etc/pip.conf.ORIG
#cp $HOME/.config/pip/pip.conf /etc/pip.conf
}

setup_pip_conf_trust_cert

cat $HOME/.config/pip/pip.conf

#curl -k -sSL https://bootstrap.pypa.io/get-pip.py -o get-pip.py
#python3 get-pip.py

