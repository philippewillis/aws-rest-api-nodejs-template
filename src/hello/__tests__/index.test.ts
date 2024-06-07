import helloModule from '..'

describe('Hello route', () => {
  it('should return "Hello World"', () => {
    expect(helloModule.get()).toBe('Hello World')
  })
})
