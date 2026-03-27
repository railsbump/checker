module EnvHelper
  def with_env(overrides)
    originals = overrides.each_key.to_h { |key| [key, ENV[key]] }
    overrides.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    yield
  ensure
    originals.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end
end
