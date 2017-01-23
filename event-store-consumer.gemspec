# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'event_store-consumer'
  s.version = '0.4.0.0.pre1'
  s.summary = 'EventStore consumer (position tracking, retries, snapshots, etc.)'

  s.authors = ['The Eventide Project']
  s.email = 'opensource@eventide-project.org'
  s.homepage = 'https://github.com/eventide-project/event-store-consumer'
  s.licenses = ['MIT']

  s.require_paths = ['lib']
  s.files = Dir.glob '{lib}/**/*'
  s.platform = Gem::Platform::RUBY

  s.add_runtime_dependency 'ntl-actor'

  s.add_runtime_dependency 'evt-consumer-event_store'
  s.add_runtime_dependency 'evt-messaging-event_store'
  s.add_runtime_dependency 'event_store-messaging', '>= 0.7.0.0.pre1'

  s.add_development_dependency 'process_host'
  s.add_development_dependency 'test_bench'
end
