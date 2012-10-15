# encoding: UTF-8

# Original Rumble tests (c) 2011 Magnus Holm (https://github.com/judofyr).

require 'helper'

Rumble = Keynote::Rumble

class TestRumble < MiniTest::Unit::TestCase
  include Rumble

  def assert_rumble(str, &blk)
    exp = str.gsub(/(\s+(<)|>\s+)/) { $2 || '>' }
    res = nil
    html {
      res = yield.to_s
    }
    assert_equal exp, res
  end

  def setup
    super
    assert_nil @rumble_context
  end

  def teardown
    super
    assert_nil @rumble_context
  end

  def test_simple
    str = <<-HTML
      <form>
        <div id="wrapper">
          <h1>My Site</h1>
        </div>
        <div class="input">
          <input type="text" name="value">
        </div>
      </form>
    HTML

    assert_rumble str do
      form do
        div.wrapper! do
          h1 "My Site"
        end

        div.input do
          input type: 'text', name: 'value'
        end
      end
    end
  end

  def test_capture
    str = <<-HTML
      <p>&lt;br&gt;</p>
    HTML

    assert_rumble str do
      p html { br }
    end
  end

  def test_several
    str = <<-HTML
      <p>Hello</p>
      <p>World</p>
    HTML

    assert_rumble str do
      p "Hello"
      p "World"
    end
  end

  def test_several_capture
    str = <<-HTML
      <div>
        <p>Hello</p>
        <p>Hello</p>
        |
        <p>World</p>
        <p>World</p>
      </div>
    HTML

    assert_rumble str do
      div do
        %w[Hello World].map { |x| html { p x; p x } } * '|'
      end
    end
  end

  def test_capture_raise
    assert_raises RuntimeError do
      html {
        div do
          html { raise }
        end
      }
    end
  end

  def test_escape
    str = <<-HTML
      <p class="&quot;test&quot;">Hello &amp; World</p>
    HTML

    assert_rumble str do
      p "Hello & World", :class => '"test"'
    end
  end

  def test_multiple_css_classes
    str = <<-HTML
      <p class="one two three"></p>
    HTML

    assert_rumble str do
      p.one.two.three
    end
  end

  def test_selfclosing
    assert_rumble "<br>" do
      br
    end
  end

  def test_text
    assert_rumble "hello" do
      text "hello"
    end
  end

  def test_error_tags_outside_rumble_context
    assert_raises Rumble::Error do
      div "content"
    end
  end

  def test_error_selfclosing_content
    assert_raises Rumble::Error do
      html {
        br "content"
      }
    end
  end

  def test_error_css_proxy_continue
    assert_raises Rumble::Error do
      html {
        p.one("test").two
      }
    end
  end

  # The real test here is if @rumble_context is nil in the teardown.
  def test_error_general
    assert_raises RuntimeError do
      html {
        div do
          raise
        end
      }
    end
  end
end
