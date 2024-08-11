# Use the ARG command to define the Node version as a build argument
ARG NODE_VERSION=18.18.2-slim
FROM node:${NODE_VERSION} as base

ENV USER=evobot

# Install necessary packages and remove unnecessary files
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 build-essential && \
    apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user and set the working directory
RUN groupadd -r ${USER} && \
    useradd --create-home --home /home/evobot -r -g ${USER} ${USER}

USER ${USER}
WORKDIR /home/evobot

FROM base as build

COPY --chown=${USER}:${USER} . .
RUN npm ci
RUN npm run build

# Remove development dependencies
RUN rm -rf node_modules && \
    npm ci --omit=dev

FROM node:${NODE_VERSION} as prod

COPY --chown=${USER}:${USER} package*.json ./
COPY --from=build --chown=${USER}:${USER} /home/evobot/node_modules ./node_modules
COPY --from=build --chown=${USER}:${USER} /home/evobot/dist ./dist

# Expose the port used by the Express server
EXPOSE 3000

CMD [ "node", "./dist/index.js" ]
