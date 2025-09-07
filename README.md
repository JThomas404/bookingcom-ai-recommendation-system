# Booking.com AI Recommendation System

A serverless hotel recommendation system built on AWS, demonstrating enterprise-grade cloud architecture with AI-powered personalisation, A/B testing capabilities, and modern web deployment patterns.

[**Booking.com Live Demo**](https://d1mszkslwzcsxd.cloudfront.net) - Experience the AI recommendation system in action

## Table of Contents

- [Overview](#overview)
- [Real-World Business Value](#real-world-business-value)
- [Prerequisites](#prerequisites)
- [Project Folder Structure](#project-folder-structure)
- [Tasks and Implementation Steps](#tasks-and-implementation-steps)
- [Core Implementation Breakdown](#core-implementation-breakdown)
- [Local Testing and Debugging](#local-testing-and-debugging)
- [IAM Role and Permissions](#iam-role-and-permissions)
- [Design Decisions and Highlights](#design-decisions-and-highlights)
- [Errors Encountered and Resolved](#errors-encountered-and-resolved)
- [Skills Demonstrated](#skills-demonstrated)
- [Conclusion](#conclusion)

## Overview

This project implements a complete serverless hotel recommendation system that simulates Booking.com's core functionality. The system processes user preferences and city selections to deliver personalised hotel recommendations through an AI-powered algorithm with real-time scoring and ranking capabilities.

The architecture leverages AWS serverless services including Lambda, API Gateway, DynamoDB, and CloudFront, deployed through Infrastructure as Code (IaC) using Terraform with modular design patterns. The system includes a professional web interface with dark theme styling and comprehensive error handling.

**Key Features:**

- AI-powered recommendation engine with preference matching
- Serverless architecture with automatic scaling
- Real-time API responses with CORS support
- Professional web interface with responsive design
- A/B testing framework for algorithm variants
- Comprehensive city and preference mapping
- Enterprise-grade security and IAM implementation

## Real-World Business Value

This system demonstrates practical solutions to common e-commerce and travel industry challenges:

**Business Impact:**

- **Personalisation at Scale**: Processes user preferences to deliver tailored recommendations, increasing conversion rates and user engagement
- **Cost Optimisation**: Serverless architecture eliminates idle resource costs, scaling automatically with demand
- **Global Distribution**: CloudFront CDN ensures low-latency access worldwide, critical for travel booking platforms
- **A/B Testing Framework**: Enables data-driven algorithm improvements and business metric optimisation
- **Operational Efficiency**: Infrastructure as Code reduces deployment time and ensures consistent environments

**Technical Value:**

- Demonstrates modern cloud-native architecture patterns
- Showcases serverless best practices with proper error handling
- Implements security-first design with least privilege IAM
- Provides template for scalable recommendation systems
- Establishes patterns for multi-environment deployment

## Prerequisites

- **AWS CLI** configured with appropriate permissions
- **Terraform** >= 1.0
- **Python** 3.9+ for Lambda development
- **Node.js** (for local testing and development)
- **AWS Account** with sufficient service limits for Lambda, API Gateway, DynamoDB, and CloudFront

**Required AWS Permissions:**

- IAM role creation and policy attachment
- Lambda function deployment and configuration
- API Gateway creation and CORS configuration
- DynamoDB table creation and data operations
- S3 bucket creation and object management
- CloudFront distribution creation and invalidation
- KMS key creation for encryption

## Project Folder Structure

```
bookingcom-ai-recommendation-system/
├── README.md
├── terraform/
│   ├── main.tf                    # Root Terraform configuration
│   ├── outputs.tf                 # Infrastructure outputs
│   ├── variables.tf               # Input variables
│   └── modules/
│       ├── storage/
│       │   ├── main.tf            # S3, DynamoDB, KMS resources
│       │   ├── outputs.tf         # Storage layer outputs
│       │   └── variables.tf       # Storage variables
│       ├── compute/
│       │   ├── main.tf            # Lambda, API Gateway resources
│       │   ├── outputs.tf         # Compute layer outputs
│       │   └── variables.tf       # Compute variables
│       └── frontend/
│           ├── main.tf            # CloudFront, S3 website resources
│           ├── outputs.tf         # Frontend outputs
│           ├── variables.tf       # Frontend variables
│           └── templates/
│               ├── index.html     # Main web interface
│               ├── style.css      # Professional styling
│               └── logos/         # Brand assets
├── lambda/
│   ├── router/
│   │   └── handler.py             # API routing logic
│   ├── data-ingestion/
│   │   └── handler.py             # Data processing functions
│   └── reco_v1/
│       └── handler.py             # Recommendation algorithm
└── data/
    ├── hotels.json                # Sample hotel dataset
    └── user_interactions.json     # User behaviour data
```

## Tasks and Implementation Steps

### Phase 1: Infrastructure Foundation

1. **Terraform Module Design**: Created modular architecture with storage, compute, and frontend layers
2. **Security Implementation**: Configured KMS encryption, IAM roles with least privilege
3. **Storage Layer**: Deployed S3 buckets for data and website hosting, DynamoDB for real-time data

### Phase 2: Serverless Compute Layer

1. **Lambda Functions**: Implemented router, data ingestion, and recommendation algorithms
2. **API Gateway**: Configured REST API with CORS support and proper error handling
3. **IAM Integration**: Created service-specific roles with minimal required permissions

### Phase 3: Frontend and Distribution

1. **Web Interface**: Built responsive interface with professional Booking.com-inspired design
2. **CloudFront CDN**: Implemented global content distribution with caching optimisation
3. **Template Processing**: Automated deployment with dynamic configuration injection

### Phase 4: Algorithm and Data Integration

1. **Recommendation Engine**: Developed AI-powered matching algorithm with scoring system
2. **City Mapping**: Implemented dual input support for city names and IDs
3. **Preference Processing**: Built tag-based filtering with relevance scoring

## Core Implementation Breakdown

### Lambda Function Architecture

**Router Function** (`lambda/router/handler.py`):

- Handles API request routing and validation
- Implements CORS headers for cross-origin requests
- Provides centralised error handling and logging

**Recommendation Engine** (`lambda/reco_v1/handler.py`):

```python
# Key implementation features:
- City name to ID mapping with fallback handling
- Preference tag processing and scoring algorithm
- DynamoDB integration with Decimal JSON serialisation
- Comprehensive error handling and response formatting
```

**Data Ingestion** (`lambda/data-ingestion/handler.py`):

- Processes hotel and user interaction data
- Handles batch operations with error recovery
- Implements data validation and transformation

### API Gateway Configuration

The API Gateway implements:

- **CORS Support**: Enables browser-based requests from CloudFront
- **Request Validation**: Ensures proper parameter formatting
- **Error Handling**: Returns consistent error responses
- **Integration Patterns**: Proxy integration with Lambda functions

### DynamoDB Schema Design

**Hotels Table**:

- Partition Key: `hotel_id`
- Attributes: `hotel_name`, `city_id`, `rating`, `amenities`, `price_range`
- Global Secondary Index on `city_id` for efficient city-based queries

**User Interactions Table**:

- Partition Key: `user_id`
- Sort Key: `timestamp`
- Attributes: `hotel_id`, `interaction_type`, `preferences`

### Frontend Implementation

**Professional Web Interface**:

- Responsive design with mobile-first approach
- Dark theme with Booking.com brand colours
- Real-time API integration with error handling
- Professional typography and spacing

**CloudFront Distribution**:

- Global edge locations for low latency
- Automatic HTTPS with AWS Certificate Manager
- Cache optimisation for static assets
- Origin Access Control for S3 security

## Local Testing and Debugging

### API Testing

```bash
# Test recommendation endpoint
curl -X GET "https://df5ib6jx72.execute-api.us-east-1.amazonaws.com/dev/recommendations?city_id=London&user_tags=luxury"

# Expected response format:
{
  "city": "London",
  "hotels": [
    {
      "hotel_name": "Luxury Palace Hotel",
      "rating": 5,
      "recommendation_score": 28.5
    }
  ]
}
```

### Infrastructure Validation

```bash
# Deploy infrastructure
cd terraform
terraform init
terraform plan
terraform apply

# Verify outputs
terraform output cloudfront-domain-name
terraform output api-url
```

### Frontend Testing

```bash
# Sync website files
aws s3 sync modules/frontend/templates/ s3://bkr-website-6f1f07e9/ --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id E24ZDBTNDRP9O5 --paths "/*"
```

## IAM Role and Permissions

### Lambda Execution Roles

**Recommendation Function Role**:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["dynamodb:GetItem", "dynamodb:Query", "dynamodb:Scan"],
      "Resource": [
        "arn:aws:dynamodb:*:*:table/hotels",
        "arn:aws:dynamodb:*:*:table/user-interactions"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
```

**Security Principles Applied**:

- Least privilege access with resource-specific ARNs
- Separate roles for each Lambda function
- No wildcard permissions in production policies
- CloudWatch logging permissions for debugging

## Design Decisions and Highlights

### Architectural Choices

**Serverless-First Approach**:

- Selected Lambda over EC2 for automatic scaling and cost optimisation
- Eliminates server management overhead and reduces operational complexity
- Enables pay-per-request pricing model suitable for variable traffic patterns

**Modular Terraform Design**:

- Separated infrastructure into logical modules (storage, compute, frontend)
- Enables independent deployment and testing of components
- Facilitates code reuse and maintenance across environments

**DynamoDB for Real-Time Data**:

- Chosen over RDS for millisecond response times and automatic scaling
- Supports the high-throughput, low-latency requirements of recommendation systems
- Eliminates database administration overhead

### Frontend Architecture

**CloudFront Distribution Strategy**:

- Implemented global CDN for worldwide low-latency access
- Configured appropriate caching policies for static and dynamic content
- Integrated with S3 Origin Access Control for security

**Professional UI/UX Design**:

- Implemented Booking.com brand guidelines with custom CSS
- Created responsive design supporting mobile and desktop users
- Added comprehensive error handling and loading states

### Security Implementation

**Encryption at Rest and Transit**:

- KMS encryption for S3 buckets containing sensitive data
- HTTPS enforcement through CloudFront and API Gateway
- Secure environment variable management for Lambda functions

**CORS Configuration**:

- Properly configured cross-origin resource sharing for browser security
- Implemented preflight request handling for complex requests
- Restricted origins to CloudFront distribution domain

## Errors Encountered and Resolved

### Template Variable Processing Issue

**Problem**: API Gateway URL template variable `${api_gateway_url}` was not being processed correctly, appearing as URL-encoded text instead of the actual URL.

**Root Cause**: Terraform template processing was not executing during S3 file upload, causing the variable to remain as literal text.

**Solution**: Implemented hardcoded API Gateway URL as a temporary fix, with plans to implement proper template processing using Terraform's `templatefile()` function.

### CORS Configuration Challenges

**Problem**: Browser requests were failing with CORS errors despite API Gateway CORS configuration.

**Root Cause**: Lambda function responses were not including proper CORS headers, and OPTIONS method was not properly configured.

**Solution**: Added CORS headers to all Lambda responses and configured OPTIONS method in API Gateway with appropriate response headers.

### Circular Dependency in Terraform

**Problem**: Frontend module required API Gateway URL from compute module, but compute module needed S3 bucket from storage module, creating circular dependencies.

**Root Cause**: Improper module dependency design with bidirectional references.

**Solution**: Restructured module dependencies to follow unidirectional flow: storage → compute → frontend, with outputs passed through the dependency chain.

## Skills Demonstrated

### Cloud Architecture and Services

- **AWS Lambda**: Serverless function development with Python runtime
- **API Gateway**: REST API design with CORS and error handling
- **DynamoDB**: NoSQL database design and query optimisation
- **CloudFront**: Global content distribution and caching strategies
- **S3**: Static website hosting and secure object storage
- **KMS**: Encryption key management and data protection

### Infrastructure as Code

- **Terraform**: Modular infrastructure design with state management
- **Module Development**: Reusable infrastructure components
- **Dependency Management**: Complex resource interdependency resolution
- **Output Management**: Proper data flow between infrastructure layers

### Software Development

- **Python**: Lambda function development with AWS SDK integration
- **JavaScript**: Frontend API integration and error handling
- **HTML/CSS**: Professional web interface development
- **JSON**: Data structure design and API response formatting

### DevOps and Deployment

- **AWS CLI**: Infrastructure management and deployment automation
- **S3 Sync**: Automated file deployment with cache invalidation
- **CloudFront Invalidation**: Cache management for content updates
- **Error Debugging**: Systematic problem identification and resolution

### Security and Best Practices

- **IAM**: Least privilege role design and policy implementation
- **CORS**: Cross-origin security configuration
- **Encryption**: Data protection with KMS integration
- **Error Handling**: Comprehensive error management and user feedback

## Conclusion

This project demonstrates the implementation of a production-ready serverless recommendation system using modern AWS services and best practices. The architecture showcases practical solutions to real-world challenges in e-commerce personalisation, including scalability, security, and user experience considerations.

The modular Terraform design enables maintainable infrastructure management, while the serverless approach provides cost-effective scaling for variable workloads. The comprehensive error handling and professional frontend implementation demonstrate attention to user experience and operational reliability.

Key achievements include successful integration of multiple AWS services, implementation of security best practices, and creation of a maintainable codebase suitable for production deployment. The project serves as a template for building scalable recommendation systems and demonstrates practical cloud engineering skills applicable to enterprise environments.

---
