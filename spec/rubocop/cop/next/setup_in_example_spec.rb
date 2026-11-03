require 'rubocop'
require 'rubocop-rspec'
require 'rubocop/rspec/support'
require_relative '../../../../lib/rubocop/cop/next_cops'

RSpec.describe RuboCop::Cop::Next::SetupInExample, :config do
  let(:config) do
    RuboCop::Config.new('RSpec' => RuboCop::ConfigLoader.default_configuration['RSpec'], described_class.cop_name => cop_config)
  end
  let(:ruby_version) { 3.4 }

  it 'registers no offense for a one-line example' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        it { is_expected.to be(true) }
      end
    RUBY
  end

  it 'registers no offense for an example built entirely of expectations' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        it 'works' do
          expect(widget.name).to eq('foo')
          expect(widget.state).to eq('active')
        end
      end
    RUBY
  end

  it 'registers no offense for setup methods inside a block expectation' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        it 'works' do
          expect { post(widgets_path, params:) }.to change(Widget, :count).by(1)
        end
      end
    RUBY
  end

  it 'registers no offense for setup methods in a hook' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        before { get(widget_path(widget)) }

        it { expect(response).to have_http_status(:ok) }
      end
    RUBY
  end

  it 'registers no offense for setup methods in a let' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        let(:widget) { create(:widget) }

        it { expect(widget).to be_persisted }
      end
    RUBY
  end

  it 'registers an offense for a local variable assignment' do
    expect_offense(<<~RUBY)
      describe Foo do
        it 'works' do
          result = described_class.call(widget)
          ^^^^^^ Move this assignment out of the example - declare it with `let!` or set it up in `before`.
          expect(result).to be_success
        end
      end
    RUBY
  end

  it 'registers an offense for a multiple assignment' do
    expect_offense(<<~RUBY)
      describe Foo do
        it 'works' do
          first, second = described_class.call(widget)
          ^^^^^^^^^^^^^ Move this assignment out of the example - declare it with `let!` or set it up in `before`.
          expect(first).to eq(second)
        end
      end
    RUBY
  end

  it 'registers an offense for an operator assignment' do
    expect_offense(<<~RUBY)
      describe Foo do
        it 'works' do
          count = 0
          ^^^^^ Move this assignment out of the example - declare it with `let!` or set it up in `before`.
          count += 1
          ^^^^^ Move this assignment out of the example - declare it with `let!` or set it up in `before`.
          expect(count).to eq(1)
        end
      end
    RUBY
  end

  it 'registers an offense for an assignment inside `aggregate_failures`' do
    expect_offense(<<~RUBY)
      describe Foo do
        it 'works' do
          aggregate_failures do
            result = described_class.call(widget)
            ^^^^^^ Move this assignment out of the example - declare it with `let!` or set it up in `before`.
            expect(result).to be_success
          end
        end
      end
    RUBY
  end

  it 'registers an offense for an HTTP verb' do
    expect_offense(<<~RUBY)
      describe Foo do
        it 'works' do
          get(widget_path(widget))
          ^^^ Move this setup out of the example - only expectations belong in an example. Set it up in `before`.
          expect(response).to have_http_status(:ok)
        end
      end
    RUBY
  end

  it 'registers an offense for a factory call' do
    expect_offense(<<~RUBY)
      describe Foo do
        it 'works' do
          create(:widget, owner:)
          ^^^^^^ Move this setup out of the example - only expectations belong in an example. Set it up in `before`.
          expect(owner.widgets.count).to eq(1)
        end
      end
    RUBY
  end

  it 'registers an offense for a stub' do
    expect_offense(<<~RUBY)
      describe Foo do
        it 'works' do
          allow(Widget).to receive(:find).and_return(widget)
          ^^^^^ Move this setup out of the example - only expectations belong in an example. Set it up in `before`.
          expect(described_class.call).to be_success
        end
      end
    RUBY
  end

  it 'registers no offense for a block that only wraps expectations' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        it 'works' do
          [true, false].each do |value|
            expect(described_class.new(value:)).to be_valid
          end
        end
      end
    RUBY
  end

  it 'registers an offense for setup inside a block that wraps expectations' do
    expect_offense(<<~RUBY)
      describe Foo do
        it 'works' do
          records.each do |record|
            record.destroy
                   ^^^^^^^ Move this setup out of the example - only expectations belong in an example. Set it up in `before`.
            expect(record).not_to be_destroyed
          end
        end
      end
    RUBY
  end

  it 'registers an offense for an action called on a receiver' do
    expect_offense(<<~RUBY)
      describe Foo do
        it 'works' do
          described_class.fetch(:items)
          ^^^^^^^^^^^^^^^ Move this setup out of the example - only expectations belong in an example. Set it up in `before`.
          expect(Client).to have_received(:call)
        end
      end
    RUBY
  end

  it 'registers an offense for an action called on a constant' do
    expect_offense(<<~RUBY)
      describe Foo do
        it 'works' do
          Widget.destroy_all
                 ^^^^^^^^^^^ Move this setup out of the example - only expectations belong in an example. Set it up in `before`.
          expect(Widget.count).to eq(0)
        end
      end
    RUBY
  end

  it 'registers an offense inside a focused example' do
    expect_offense(<<~RUBY)
      describe Foo do
        fit 'works' do
          sign_in(user)
          ^^^^^^^ Move this setup out of the example - only expectations belong in an example. Set it up in `before`.
          expect(page).to have_content('Hi')
        end
      end
    RUBY
  end

  it 'registers an offense inside a Capybara `scenario`' do
    expect_offense(<<~RUBY)
      feature 'Widgets' do
        scenario 'works' do
          click_on('Go')
          ^^^^^^^^ Move this setup out of the example - only expectations belong in an example. Set it up in `before`.
          expect(page).to have_content('Hi')
        end
      end
    RUBY
  end

  it 'registers an offense inside a skipped Capybara `scenario`' do
    expect_offense(<<~RUBY)
      feature 'Widgets' do
        xscenario 'works' do
          click_on('Go')
          ^^^^^^^^ Move this setup out of the example - only expectations belong in an example. Set it up in `before`.
          expect(page).to have_content('Hi')
        end
      end
    RUBY
  end

  it 'registers no offense for `skip`' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        it 'works' do
          skip('flaky on CI')
          expect(widget).to be_valid
        end
      end
    RUBY
  end

  context 'with a configured `AllowedMethods` list' do
    let(:cop_config) { { 'AllowedMethods' => ['wait_for_ajax'] } }

    it 'registers no offense for a configured method' do
      expect_no_offenses(<<~RUBY)
        describe Foo do
          it 'works' do
            wait_for_ajax
            expect(page).to have_content('Hi')
          end
        end
      RUBY
    end

    it 'registers an offense for a method dropped from the list' do
      expect_offense(<<~RUBY)
        describe Foo do
          it 'works' do
            skip('flaky on CI')
            ^^^^ Move this setup out of the example - only expectations belong in an example. Set it up in `before`.
            expect(widget).to be_valid
          end
        end
      RUBY
    end
  end
end
