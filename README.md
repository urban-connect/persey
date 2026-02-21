# Persey

Configuration DSL with environment inheritance.

This is a rewrite of the original [persey](https://github.com/zzet/persey) gem that has been used for configuration at Urban Connect for years. The original gem was no longer maintained, so we extracted and rewrote the core functionality in a backward-compatible way.

## Usage

```ruby
Persey.init(Rails.env) do
  env :default do
    app_name "my_app"
    database do
      host "localhost"
      port 5432
    end
  end

  env :production, parent: :default do
    database do
      host "db.example.com"
    end
  end
end

Persey.config.app_name          # => "my_app"
Persey.config.database.host     # => "db.example.com" (in production)
Persey.config.database.port     # => 5432 (inherited from default)
```

### Lambda values

Lambdas are evaluated in the context of the root config node:

```ruby
Persey.init(:production) do
  env :production do
    scheme "https"
    host "example.com"
    base_url -> { "#{scheme}://#{host}" }
  end
end

Persey.config.base_url # => "https://example.com"
```

## Running specs

```
bundle install
bundle exec rspec
```
