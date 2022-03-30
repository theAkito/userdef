FROM gitea/gitea:1.16.5-linux-amd64-rootless

ARG UID

USER root:root
COPY ../userdef_debug /usr/local/bin/userdef
RUN chmod +x /usr/local/bin/userdef
# COPY myuserconfig.json /
# RUN userdef myuserconfig.json
# https://stackoverflow.com/a/66974607/7061105
RUN apk add libc6-compat
RUN /usr/local/bin/userdef -h=/var/lib/gitea/git -n=git -u=9234 -g=9234
RUN set -x; cat /etc/passwd 1>&2
RUN chown git:git -R /var/lib/gitea /etc/gitea

USER ${UID}:${UID}
# Taken from https://github.com/go-gitea/gitea/blob/66f2210feca0b50d305a46a203c2b3d2f4d3790b/Dockerfile.rootless#L71-L72
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD []