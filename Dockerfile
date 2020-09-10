FROM centos:7

# configure timezone
RUN ln -fs /usr/share/zoneinfo/CET /etc/localtime

# set working directory
WORKDIR /tmp

# fetch
RUN yum -y update

# install
RUN yum -y install \
    openssh \
    openssh-clients \
    openssh-server \
    passwd \
    sudo \
    systemd

# configure systemd
ENV container docker
RUN \
    (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

# configure user
ARG UID=1000
ARG GID=1000
RUN getent group $GID >/dev/null || \
    echo "Creating group $GID" && \
    groupadd "user" -g $GID
RUN getent passwd $UID >/dev/null || \
    echo "Creating user $UID" && \
    useradd "user" -u $UID -g $GID -m -s /bin/bash && \
    echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# generate keys
RUN ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
RUN ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
RUN ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519

# prepare SSH folder
RUN mkdir -p /home/user/.ssh

# add your public key to ensure passwordless connection for user
COPY ./secret/ssh/sshkey.pub /home/user/.ssh/authorized_keys

# secure /home/user/.ssh
RUN chown -R $UID:$GID /home/user/.ssh
RUN chmod 700 /home/user/.ssh
RUN chmod 644 /home/user/.ssh/authorized_keys

# configure SSHD
RUN sed -i "s/^\(PasswordAuthentication\) yes$/\1 no/g" /etc/ssh/sshd_config
RUN sed -i "s/^\(PermitRootLogin\) yes$/\1 no/g" /etc/ssh/sshd_config
RUN sed -i "s/^\(UsePAM\) yes$/\1 no/g" /etc/ssh/sshd_config

# configure passwords
RUN echo 'root:root' | chpasswd
RUN echo 'user:user' | chpasswd

# uncover port 22
EXPOSE 22

# enable sshd
RUN systemctl enable sshd

# initialize systemD
CMD [ "/usr/sbin/init"]
