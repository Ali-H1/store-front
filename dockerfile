# Use an official Node.js image as the base image
FROM node:14

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the container
COPY isi-web/package*.json ./

# Install project dependencies
RUN npm install -f

# Copy the rest of the application code to the container
COPY isi-web .

# Build the Vue.js application for production
RUN npm run build

# Expose the port that the application will run on (default for Vue.js is 8080)
EXPOSE 8080

# Specify the command to run the application
#CMD ["npm", "run", "build"]
