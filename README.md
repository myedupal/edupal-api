# README
1. Preconfiguration    
    - refer .env.example, create your own .env file
2. To generate a scaffold (model and migration included)
    ```bash
    rails g faster:scaffold api/v1/products name:string price:monetize
    ```
3. To generate a scaffold_controller (assuming model already exists)  
   Use --skip-pundit option if you want to skip pundit code (e.g. public API)
    ```bash
    rails g faster:scaffold_controller api/v1/products name:string price:monetize { --skip-pundit }
    ```
4. To generate rswag request spec file manually (no need to do this if you use scaffold)  
   For example, api/v1/products_controller
    ```bash
    rails g rspec:swagger Api::V1::Product
    ```
5. To run rspec test and generate swagger.json
    ``` 
    # generate documentation
    bundle exec rspec spec/requests --format Rswag::Specs::SwaggerFormatter --format p --order defined
    # just run test without documentation
    bundle exec rspec spec
    ```
6. To view API documentation, visit http://localhost:3000/redoc