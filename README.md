# BlogApplicationTask-backend

A RESTful API for a simple blog application built with Ruby on Rails. This project is designed for interview and learning purposes.

## Features

- User authentication with JWT (sign up, login)
- Create, read, update, and delete blog posts
- Tagging system for posts
- Commenting on posts
- Only post owners can edit/delete their posts
- Only comment owners can edit/delete their comments
- Sidekiq for background jobs
- PostgreSQL for database
- Redis for background jobs and caching
- Docker and Docker Compose support

## Getting Started

### Prerequisites

- Docker & Docker Compose (recommended)
- Or: Ruby (3.0+), Rails (7.1+), PostgreSQL, Redis

### Setup with Docker (Recommended)

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd blog-api
   ```
2. Copy and edit environment variables as needed:
   ```bash
   ```
3. Build and start the services:
   ```bash
   docker-compose up --build
   ```
4. In a new terminal, run database migrations:
   ```bash
   docker-compose exec web rails db:create db:migrate
   ```
5. (Optional) Seed the database:
   ```bash
   docker-compose exec web rails db:seed
   ```

### Local Setup (Without Docker)

1. Install dependencies:
   ```bash
   bundle install
   ```
2. Set up the database:
   ```bash
   rails db:create db:migrate
   rails db:seed # optional
   ```
3. Start Redis and Sidekiq (for background jobs):
   ```bash
   redis-server &
   bundle exec sidekiq
   ```
4. Start the Rails server:
   ```bash
   rails server
   ```

## API Usage

Base URL: `http://localhost:3000/`

### Authentication
- `POST /signup` — Register a new user
- `POST /login` — Obtain a JWT token

### Posts
- `GET /posts` — List all posts
- `GET /posts/:id` — Show a specific post
- `POST /posts` — Create a new post (auth required)
- `PUT/PATCH /posts/:id` — Update a post (owner only)
- `DELETE /posts/:id` — Delete a post (owner only)

### Comments
- `GET /posts/:post_id/comments` — List comments for a post
- `POST /posts/:post_id/comments` — Add a comment (auth required)
- `PUT/PATCH /posts/:post_id/comments/:id` — Update a comment (owner only)
- `DELETE /posts/:post_id/comments/:id` — Delete a comment (owner only)

### Tags
- Tags are managed automatically when creating/updating posts.

### Health & Background Jobs
- `GET /healthz` — Health check endpoint
- Sidekiq dashboard: `/sidekiq` (protect in production!)

## Contributing

Feel free to submit issues or pull requests for improvements or new features.

## License

This project is open source and available under the MIT License.