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

# Copy package.json and package-lock.json first to leverage Docker cache
COPY --chown=${USER}:${USER} package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the source code
COPY --chown=${USER}:${USER} . .

# Build the project
RUN npm run build

# Remove development dependencies
RUN npm prune --production

FROM node:${NODE_VERSION} as prod

# Copy package.json and package-lock.json
COPY --chown=${USER}:${USER} package*.json ./

# Install only production dependencies
RUN npm install --only=production

# Copy built files from the build stage
COPY --from=build --chown=${USER}:${USER} /home/evobot/node_modules ./node_modules
COPY --from=build --chown=${USER}:${USER} /home/evobot/dist ./dist

# Expose the port used by the Express server
EXPOSE 3000

# Start the application
CMD [ "node", "./dist/index.js" ]
