FROM python:3-slim-bullseye
VOLUME ["/opt/rf/reports","/opt/rf/results","/opt/rf/tests","/opt/rf/data"]
COPY ./ /opt/rf/
RUN apt-get -y update && apt-get -y upgrade \
    && apt-get -y install gnupg wget curl unzip \
        && wget -O- https://dl.google.com/linux/linux_signing_key.pub \
        | gpg --dearmor > /etc/apt/trusted.gpg.d/google.gpg \
        && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
            >> /etc/apt/sources.list.d/google-chrome.list \
        && apt-get update \
        && apt-get install -y google-chrome-stable \
        && CHROME_VERSION=$(google-chrome --product-version | grep -o "[^\.]*\.[^\.]*\.[^\.]*") \
	    && CHROMEDRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION") \
	    && wget -q --continue -P /chromedriver "http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip" \
	    && unzip /chromedriver/chromedriver* -d /usr/local/bin/ \
	    && rm /etc/apt/sources.list.d/google-chrome.list \
    && rm -rf /var/lib/apt/lists \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
        && npm install npm@latest -g \
        && npm install -g create-react-app \
        && npm install -g json-server \
    && apt-get install -y procps \
    && pip3 install -r /opt/rf/requirements.txt \
    && rfbrowser init \
    && apt-get install -y netcat \
    && chmod 755 /opt/rf/scripts/*.sh \
    && mkdir -p /opt/rf/reports/ \
    && chmod 777 /opt/rf/reports/ \
    && apt-get autoremove -y \
    && apt-get clean
WORKDIR /opt/rf/
#ENTRYPOINT ["./scripts/run_pipeline.sh"]