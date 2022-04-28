from dotenv import load_dotenv
from .app import create_app


def main():
    load_dotenv()
    app = create_app()
    app.run()


if __name__ == '__main__':
    main()
