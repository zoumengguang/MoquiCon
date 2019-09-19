FROM openjdk:8-jdk
LABEL maintainer="Moqui Framework <moqui@googlegroups.com>"

WORKDIR /opt/moqui

# get latest linux distro updates
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
	&& apt-get update \
	&& apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

# add moqui user and group
RUN groupadd -g 999 moqui && \
	useradd -r -u 999 -g moqui -G audio,video moqui

# for running from the war directly, preffered approach unzips war in advance (see docker-build.sh that does this)
#COPY moqui.war .
# copy files from unzipped moqui.war file
COPY --chown=moqui:moqui WEB-INF WEB-INF
COPY --chown=moqui:moqui META-INF META-INF
COPY --chown=moqui:moqui *.class ./
COPY --chown=moqui:moqui execlib execlib

# always want the runtime directory
COPY --chown=moqui:moqui runtime runtime
COPY --chown=moqui:moqui runscript.sh runscript.sh

# exposed as volumes for configuration purposes
#VOLUME ["/opt/moqui/runtime/conf", "/opt/moqui/runtime/lib", "/opt/moqui/runtime/classes", "/opt/moqui/runtime/ecomponent"]
# exposed as volumes to persist data outside the container, recommended
#VOLUME ["/opt/moqui/runtime/log", "/opt/moqui/runtime/txlog", "/opt/moqui/runtime/sessions", "/opt/moqui/runtime/db", "/opt/moqui/runtime/elasticsearch"]
RUN find runtime -name chrome -exec chmod 764 {} + \
	&& find runtime -name node -exec chmod 764 {} +
ENV html_pdf_chromium_disable_sandbox "true"
USER moqui

# this is to run from the war file directly, preferred approach unzips war file in advance
# ENTRYPOINT ["java", "-jar", "moqui.war"]
ENTRYPOINT ["/opt/moqui/runscript.sh"]

# specify this as a default parameter if none are specified with docker exec/run, ie run production by default
CMD ["run"]