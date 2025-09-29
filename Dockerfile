# 1) Base image with Node + npm (small & efficient)
FROM node:18-alpine

# 2) Working directory inside the container
WORKDIR /app

# 3) Install newman + htmlextra globally
RUN npm install -g newman newman-reporter-htmlextra

# 4) Copy only what is needed for the run (no secrets!)
COPY postman ./postman

# 5) Default command (can be overridden via docker run)
# Secrets are NOT stored in the image; injected via ENV
CMD ["sh", "-c", "newman run \"postman/collection/GoREST Users Tests.postman_collection.json\" -e \"postman/env/GoREST Local.postman_environment.json\" --env-var token=${TOKEN} --env-var mockBaseUrl=${MOCK_BASE_URL} -r cli,htmlextra --reporter-htmlextra-export reports/newman.html --color on"]
