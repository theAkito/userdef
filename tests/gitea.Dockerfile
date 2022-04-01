FROM akito13/userdef:latest-debug AS base
FROM gitea/gitea:1.16.5-linux-amd64-rootless

ARG UID
LABEL testuserdef=true

USER root:root
COPY --from=base /userdef /userdef
RUN /userdef -h=/var/lib/gitea/git -n=git -u=${UID} -g=${UID} && \
  chown git:git -R /var/lib/gitea /etc/gitea && \
  rm -f /userdef

USER ${UID}:${UID}
# Taken from https://github.com/go-gitea/gitea/blob/66f2210feca0b50d305a46a203c2b3d2f4d3790b/Dockerfile.rootless#L71-L72
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD []