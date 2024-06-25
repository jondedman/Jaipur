# Jaipur Rails Project

This is a Ruby on Rails application for implementing the game of Jaipur with real-time 2-player turn-taking using web sockets.

## Requirements

- Ruby 3.1.2
- Rails 7.0.8
- PostgreSQL

## Branches

### `main` Branch

The `main` branch contains the stable version of the project without real-time 2-player turn-taking. This branch is suitable for production use and for those who want a stable version without the new real-time feature.

### `realtime-feature` Branch

The `realtime-feature` branch includes the implementation of web sockets for real-time 2-player turn-taking. This branch is where the latest development for real-time features is happening. Use this branch if you want to test or contribute to the development of real-time functionality.

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/yourusername/jaipur.git
cd jaipur
```

### Checkout the Desired Branch

By default, the main branch will be checked out. If you want to use the realtime-feature branch, switch to it:

```bash
git checkout realtime-feature
```

### Install Dependencies

```bash
bundle install
```

### Database Setup

Ensure you have PostgreSQL installed and running. Then, set up the database:

```bash
rails db:create
rails db:migrate
```

### Configuration

Ensure you have the necessary environment variables set up, such as database credentials. You can use a .env file or configure them directly in your system.

### Running the Server

Start the Rails server:

```bash
rails server
```

By default, the server runs on http://localhost:3000.

## Features

- Real-time 2-player turn-taking using web sockets (only in realtime-feature branch)
- User authentication with Devise
- Responsive design using Tailwind CSS

## Gems Used

- rails (~> 7.0.8): Core Rails framework
- sprockets-rails: Asset pipeline
- pg (~> 1.2): PostgreSQL database adapter
- puma (~> 5.0): Web server
- devise: Authentication
- importmap-rails: JavaScript module bundler
- turbo-rails: SPA-like page updates
- stimulus-rails: JavaScript framework
- jbuilder: JSON APIs
- redis (~> 4.0): Redis adapter for Action Cable
- tzinfo-data: Timezone data for Windows
- bootsnap: Caches expensive operations for faster boot times
- debug: Debugging tools
- web-console: Console on exceptions pages
- capybara: Integration testing
- selenium-webdriver: Browser automation
- tailwindcss-rails (~> 2.1): Tailwind CSS integration
