---
skill: "Building FastAPI Endpoints"
domain: "backend"
agent: "Backend Specialist"
version: "2.1.0"
status: "active"
---

# Building FastAPI Endpoints

## Overview
This skill defines the standard pattern for creating REST API endpoints using FastAPI with proper validation, error handling, and documentation.

## Context

### Use Cases
- Creating new REST API routes
- Implementing CRUD operations
- Exposing backend functionality to frontend clients
- Building microservices with consistent patterns

### Prerequisites
- FastAPI installed (`pip install fastapi`)
- Pydantic for validation (`pip install pydantic`)
- Python 3.9+ with type hints
- Understanding of HTTP methods and status codes

### When NOT to Use
- Internal helper functions (use regular functions)
- Background tasks (use Celery or FastAPI background tasks)
- WebSocket handlers (use WebSocket-specific patterns)
- GraphQL endpoints (use Strawberry or Graphene)

## Rules

### Must Do
- ✅ Use Pydantic models for all request/response schemas
- ✅ Include type hints on all function parameters
- ✅ Add docstrings with example requests and responses
- ✅ Return appropriate HTTP status codes (200, 201, 400, 404, 500)
- ✅ Use dependency injection for database sessions
- ✅ Validate input data before processing
- ✅ Log errors with context

### Must Not Do
- ❌ Return raw database ORM objects (use Pydantic models)
- ❌ Use mutable default arguments (`list=[]`, `dict={}`)
- ❌ Skip input validation (trust user input)
- ❌ Expose internal implementation details in responses
- ❌ Use synchronous I/O for database or external APIs
- ❌ Return 200 for errors with error messages in body

### Best Practices
- 🎯 Use async/await for I/O operations
- 🎯 Group related endpoints with APIRouter
- 🎯 Use dependency injection for authentication
- 🎯 Keep endpoint logic thin (delegate to service layer)
- 🎯 Write integration tests for all endpoints

## Implementation Guide

### Step 1: Define Pydantic Models

Create request and response schemas with validation:

```python
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime
from typing import Optional

class UserCreateRequest(BaseModel):
    """Request schema for creating a new user."""
    email: EmailStr  # Validates email format
    name: str = Field(..., min_length=1, max_length=100)
    age: Optional[int] = Field(None, ge=0, le=150)
    
    class Config:
        json_schema_extra = {
            "example": {
                "email": "john.doe@example.com",
                "name": "John Doe",
                "age": 30
            }
        }

class UserResponse(BaseModel):
    """Response schema for user data."""
    id: int
    email: str
    name: str
    age: Optional[int]
    created_at: datetime
    
    class Config:
        from_attributes = True  # Enable ORM mode
```

### Step 2: Create the Endpoint

Implement the route with proper error handling:

```python
from fastapi import APIRouter, HTTPException, Depends, status
from sqlalchemy.orm import Session
from typing import List

router = APIRouter(prefix="/api/v1/users", tags=["users"])

def get_db():
    """Dependency for database session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post(
    "/",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new user",
    description="Creates a new user account with the provided information."
)
async def create_user(
    user_data: UserCreateRequest,
    db: Session = Depends(get_db)
) -> UserResponse:
    """
    Create a new user.
    
    Args:
        user_data: User information to create
        db: Database session (injected)
    
    Returns:
        UserResponse: Created user data
    
    Raises:
        HTTPException: 400 if email already exists
        HTTPException: 500 if database error occurs
    """
    # Check if user already exists
    existing_user = db.query(User).filter(User.email == user_data.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User with this email already exists"
        )
    
    try:
        # Create new user
        new_user = User(
            email=user_data.email,
            name=user_data.name,
            age=user_data.age
        )
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        
        return UserResponse.from_orm(new_user)
    
    except SQLAlchemyError as e:
        db.rollback()
        logger.error(f"Database error creating user: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create user"
        )
```

### Step 3: Add to Application

Register the router in your main FastAPI app:

```python
from fastapi import FastAPI
from app.routes import users

app = FastAPI(
    title="My API",
    version="1.0.0",
    description="API for managing users"
)

app.include_router(users.router)
```

## Common Pitfalls

### Pitfall 1: Mutable Default Arguments
**Problem**: Using `list` or `dict` as default parameter values causes state to leak between requests.

**Solution**: Use `None` and initialize inside the function.

**Example**:
```python
# ❌ WRONG - Dictionary is shared across all calls
def get_users(filters: dict = {}):
    filters["deleted"] = False  # Modifies shared object!
    return db.query(User).filter_by(**filters).all()

# ✅ CORRECT - New dictionary for each call
def get_users(filters: dict | None = None):
    filters = filters or {}
    filters["deleted"] = False
    return db.query(User).filter_by(**filters).all()
```

### Pitfall 2: Returning ORM Objects Directly
**Problem**: Exposes internal database structure, causes lazy-loading issues, and leaks sensitive data.

**Solution**: Always convert to Pydantic models before returning.

**Example**:
```python
# ❌ WRONG - Returns SQLAlchemy object
@router.get("/users/{user_id}")
async def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    return user  # Bad: includes password hash, internal IDs, etc.

# ✅ CORRECT - Returns Pydantic model
@router.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return UserResponse.from_orm(user)
```

### Pitfall 3: Missing Error Handling
**Problem**: Unhandled exceptions return 500 errors with stack traces to users.

**Solution**: Wrap database operations in try/except and return appropriate status codes.

**Example**:
```python
# ❌ WRONG - No error handling
@router.delete("/users/{user_id}")
async def delete_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).get(user_id)
    db.delete(user)  # Crashes if user is None!
    db.commit()
    return {"message": "User deleted"}

# ✅ CORRECT - Proper error handling
@router.delete("/users/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).get(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User with id {user_id} not found"
        )
    
    try:
        db.delete(user)
        db.commit()
    except SQLAlchemyError as e:
        db.rollback()
        logger.error(f"Error deleting user {user_id}: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete user"
        )
```

### Pitfall 4: Blocking I/O in Async Endpoints
**Problem**: Using synchronous database calls blocks the event loop.

**Solution**: Use async database drivers or run sync code in thread pool.

**Example**:
```python
# ❌ WRONG - Blocks event loop
@router.get("/users")
async def list_users(db: Session = Depends(get_db)):
    users = db.query(User).all()  # Synchronous call in async function!
    return users

# ✅ CORRECT - Use async database driver
from sqlalchemy.ext.asyncio import AsyncSession

@router.get("/users")
async def list_users(db: AsyncSession = Depends(get_async_db)):
    result = await db.execute(select(User))
    users = result.scalars().all()
    return users
```

## Testing

### How to Verify
- [ ] Endpoint returns correct status codes (201, 200, 404, etc.)
- [ ] Response matches Pydantic schema exactly
- [ ] Error cases return proper error messages
- [ ] API documentation is auto-generated at `/docs`
- [ ] Input validation rejects invalid data
- [ ] Database transactions are rolled back on errors

### Test Cases

```python
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_create_user_success():
    """Test successful user creation."""
    response = client.post(
        "/api/v1/users/",
        json={
            "email": "test@example.com",
            "name": "Test User",
            "age": 25
        }
    )
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "test@example.com"
    assert "id" in data
    assert "created_at" in data

def test_create_user_duplicate_email():
    """Test creating user with existing email fails."""
    # Create first user
    client.post(
        "/api/v1/users/",
        json={"email": "duplicate@example.com", "name": "User 1"}
    )
    
    # Try to create duplicate
    response = client.post(
        "/api/v1/users/",
        json={"email": "duplicate@example.com", "name": "User 2"}
    )
    assert response.status_code == 400
    assert "already exists" in response.json()["detail"]

def test_create_user_invalid_email():
    """Test validation rejects invalid email."""
    response = client.post(
        "/api/v1/users/",
        json={"email": "not-an-email", "name": "Test"}
    )
    assert response.status_code == 422  # Validation error

def test_get_user_not_found():
    """Test getting non-existent user returns 404."""
    response = client.get("/api/v1/users/99999")
    assert response.status_code == 404
```

## Related Skills
- `Database Transactions` - Ensure data consistency
- `API Authentication` - Add JWT auth to endpoints
- `Error Logging` - Track API errors
- `API Versioning` - Version your endpoints

## References
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Pydantic Validation](https://docs.pydantic.dev/latest/)
- [HTTP Status Codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)
- [REST API Best Practices](https://restfulapi.net/)

## Changelog

### Version 2.1.0 (2024-01-15)
- Added: Section on async database drivers
- Added: More test examples
- Fixed: Pitfall #4 example code

### Version 2.0.0 (2023-12-01)
- BREAKING: Changed from dict responses to Pydantic models
- Added: Dependency injection pattern
- Added: Error logging examples

### Version 1.0.0 (2023-10-15)
- Initial skill definition
- Basic CRUD endpoint pattern
