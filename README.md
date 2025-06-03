# XM Cloud Click, Click, Launch Repo

This repository contains the codebase for Sites 1, 2, and 3 of the XM Cloud Click, Click, Launch demo. The demo is designed to showcase the capabilities of Sitecore XM Cloud and how it can be used to build modern web applications.

### Prerequisites

- Access to an Sitecore XM Cloud Environment
- [Node.js LTS](https://nodejs.org/en/)

### Getting Started Guide

For developers new to XM Cloud you can follow the Getting Started Guide on the [Sitecore Documentation Site](https://doc.sitecore.com/xmc) to get up and running with XM Cloud. This will walk you through the process of creating a new XM Cloud Project, provisioning an Environment, deploying the NextJs Starter Kit, and finally creating your first Component.

### Running the Next.js Content-SDK Starter Kit

- Log into the Sitecore XM Cloud Deploy Portal, locate your Environment and select the `Developer Settings` tab.
- Ensure that the `Preview` toggle is enabled.
- In the `Local Development` section, click to copy the sample `.env` file contents to your clipboard.
- Create a new `.env.local` file in the `./headapps/nextjs` folder of this repository and paste the contents from your clipboard.
- Run the following commands in the root of the repository to start the NextJs application:
  ```bash
  cd headapps/nextjs
  npm install
  npm run start:connected
  ```
- You should now be able to access your site on `http://localhost:3000` and see your changes in real-time as you make them.

