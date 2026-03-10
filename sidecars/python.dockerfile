# versions: see apt-cache policy python3 python3-pip to query current
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*
