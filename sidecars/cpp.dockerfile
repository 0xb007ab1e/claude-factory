# versions: see apt-cache policy build-essential cmake gdb clang-format to query current
RUN apt-get update && apt-get install -y build-essential cmake gdb clang-format && rm -rf /var/lib/apt/lists/*
