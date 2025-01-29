# Usar uma imagem Python Slim para otimização de espaço
FROM python:3.12-slim AS python-base

# Variáveis de ambiente
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=1.8.4 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    PATH="/opt/poetry/bin:$PATH"

# Instalar dependências e o Poetry
RUN apt-get update && apt-get install --no-install-recommends -y \
        curl build-essential libpq-dev gcc libc-dev \
    && curl -sSL https://install.python-poetry.org | python3 - \
    && poetry --version \
    && poetry self update $POETRY_VERSION \
    && apt-get purge --auto-remove -y build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configurar o Poetry
RUN poetry config virtualenvs.create true \
    && poetry config virtualenvs.in-project true

# Copiar arquivos de configuração do Poetry
WORKDIR /app
COPY poetry.lock pyproject.toml ./

# Instalar dependências do Poetry (runtime)
RUN poetry install --only main

# Copiar código-fonte do projeto
COPY . .

# Expor a porta padrão do Django
EXPOSE 8000

# Comando padrão para rodar o servidor
CMD ["poetry", "run", "python", "manage.py", "runserver", "0.0.0.0:8000"]