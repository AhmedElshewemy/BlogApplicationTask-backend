# BlogApplicationTask-backend
task for interview BlogApplicationTask-backend create a RESTful API

# Blog API

This is a simple blog application built with Ruby on Rails that provides a RESTful API for managing blog posts.

## Features

- Create, read, update, and delete blog posts.
- JSON responses for API requests.
- Basic validations for post attributes.

## Getting Started

### Prerequisites

- Ruby (version 2.7 or higher)
- Rails (version 6.0 or higher)
- PostgreSQL (or your preferred database)

### Installation

1. Clone the repository:

   ```
   git clone <repository-url>
   ```

2. Navigate to the project directory:

   ```
   cd blog-api
   ```

3. Install the required gems:

   ```
   bundle install
   ```

4. Set up the database:

   ```
   rails db:create
   rails db:migrate
   ```

### Usage

To start the server, run:

```
rails server
```

You can access the API at `http://localhost:3000/api/v1/posts`.

### API Endpoints

- `GET /api/v1/posts` - List all posts
- `GET /api/v1/posts/:id` - Show a specific post
- `POST /api/v1/posts` - Create a new post
- `PATCH/PUT /api/v1/posts/:id` - Update a specific post
- `DELETE /api/v1/posts/:id` - Delete a specific post

### Contributing

Feel free to submit issues or pull requests for any improvements or features.

### License

This project is open source and available under the MIT License.