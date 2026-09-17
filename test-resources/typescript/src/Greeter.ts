export class Greeter<T> {
  constructor(private readonly value: T) {}

  greet(name: string): string {
    return `Hello, ${name}`;
  }

  result(): T {
    return this.value;
  }
}
