resource "heroku_app" "rent_your_stuff_staging" {
  name   = "rent_your_stuff_staging"
  region = "eu"

  config_vars = {
    FOOBAR = "baz"
  }

  buildpacks = [
    "heroku/gradle"
  ]
}

resource "heroku_addon" "rent_your_stuff_staging_db" {
  app_id = heroku_app.rent_your_stuff_staging.id
  plan   = "heroku-postgresql:hobby-dev"
}

resource "heroku_pipeline" "rent_your_stuff_pipeline" {
  name = "rent-your-stuff-pipeline"
}

# Соединяем приложение с конвеером
resource "heroku_pipeline_coupling" "staging_pipeline_coupling" {
  app_id   = heroku_app.rent_your_stuff_staging.id
  pipeline = heroku_pipeline.rent_your_stuff_pipeline.id
  stage    = "staging"
}

# Добавим интеграцию конвеера с репозиторием гита
resource "herokux_pipeline_github_integration" "pipeline_integration" {
  pipeline_id = heroku_pipeline.rent_your_stuff_pipeline.id
  arg_repo    = "vgladkikh/rent-your-stuff"
}

# добавим интеграцию хероку и гита
resource "herokux_app_github_integration" "rent_your_stuff_gh_integration" {
  app_id      = heroku_app.rent_your_stuff_staging.uuid
  branch      = "main"
  auto_deploy = true
  wait_for_ci = true

  # укажем что должно срабатывать только
  # после работы конвеера herokux_pipeline_github_integration
  depends_on = [herokux_pipeline_github_integration.pipeline_integration]
}