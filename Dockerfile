FROM golang:1.24 AS builder

# Set working directory
WORKDIR /app

# Copy go.mod and go.sum files first for better cache
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o /registry ./cmd/registry

# Final stage
FROM gcr.io/distroless/static:nonroot

WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /registry /app/registry
COPY data /app/data

# Use non-root user
USER nonroot:nonroot

# Command to run
ENTRYPOINT ["/app/registry"]