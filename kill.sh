jps | grep Client | grep -v grep | cut -c 1-6 | xargs kill -9