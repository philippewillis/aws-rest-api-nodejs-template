import helloModule from '..'

describe('exampleModule', () => {
  it('should return "Hello World"', () => {
    expect(helloModule.get()).toBe('Hello World')
  })
})
