FROM khulnasoft/primeagfent:1.0-alpha

CMD ["python", "-m", "primeagfent", "run", "--host", "0.0.0.0", "--port", "7860"]
