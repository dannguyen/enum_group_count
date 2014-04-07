require 'spec_helper'

describe 'enum_group_count' do
  alias_method :gcount, :enum_group_count


  describe 'end-to-end demo' do
    let(:collection){ ['Sarah Taylor', 'Sam Smith', 'Zelda Fitzgerald', 'Bob Smith', 'Kurt Fitzgerald', 'Bob Bob']}
    let(:opts){ {} }
    let(:last_name_foo){ ->(v){ v.split(' ')[1] }   }
    let(:g){ gcount collection, opts, &last_name_foo}

    context 'end to end and bees knees'  do
      it 'has lots o things' do

        coll =  gcount( collection, :sort => {:count => :desc} ){ |val| val.split(' ').last } # last name

        expect(coll.keys).to eq %w(Fitzgerald Smith Bob Taylor)

        expect( coll ).to eq(
          {
            'Fitzgerald' => 2,
            'Smith' => 2,
            'Taylor' => 1,
            'Bob' => 1
          }
        )

      end


      it 'by default, :sort by ascending key' do
        expect(g.keys).to eq %w(Bob Fitzgerald Smith Taylor)
        expect(g.values).to eq [1, 2, 2, 1]
      end

      it 'or :sort by descending keys' do
        opts[:sort] = {:keys => :desc}
        expect(g.keys).to eq %w(Taylor Smith Fitzgerald Bob)
        expect(g.values).to eq [1, 2, 2, 1]
      end


      it 'can :sort by :count (ascends by default)' do
        opts[:sort] = :count
        expect(g.keys).to eq %w(Bob Taylor Fitzgerald Smith)
        expect(g.values).to eq [1, 1, 2, 2]
      end

      it 'can :sort :count in descending order and keep keys in alpha order' do
        opts[:sort] = {:count => :desc}
        expect(g.keys).to eq %w(Fitzgerald Smith Bob Taylor)
      end

      it 'in combination' do
        opts[:sort] = {:count => :desc, :keys => :desc}
        expect(g.keys).to eq %w(Smith Fitzgerald Taylor Bob)
        expect(g.values).to eq [2, 2, 1, 1]
      end
    end
  end # end to end


  describe 'arguments' do
    describe 'first is a collection'  do
      it 'accepts an Enumerable' do
        expect(gcount([])).to be_a Hash
        expect(gcount(1..3)).to be_a Hash
      end

      it 'rejects non-Enumerables' do
        expect{ gcount("1,2,3") }.to raise_error ArgumentError
      end
    end

    describe 'block' do
      let(:collection){ [2, 1, 3, 4, 1] }

      context 'when omitted' do
        it 'groups by value-equality' do
          expect(gcount(collection)).to eq( { 1 => 2, 2 => 1, 3 => 1, 4 => 1  } )
        end
      end

      context 'when provided' do
        it 'groups by result of given block' do
          expect(gcount(collection){ |v| v % 2  }).to eq ({0 => 2, 1 => 3})
        end
      end
    end

    describe 'second arg: options Hash' do
      context 'is blank' do
        let(:collection){ [2, 1, 1, 3] }
        subject{ gcount(collection) }

        it{ be_an Hash }
        it{ eq( {1 => 2, 2 => 1, 3 => 1} ) }
      end

      context 'are set' do
        describe ':sort =>' do

          let(:collection){ [3, 3, 2, 4, 5, 4, 1, 1, 4] }
          let(:options){ {} }
          let(:g){ gcount(collection, options) }

          it 'always sorts by :keys ascending by default' do
             expect( g.keys ).to eq [1, 2, 3, 4, 5]
          end

          describe :keys  do
            it 'as standalone symbol will just enact default :keys ascending sort' do
              options[:sort] = :keys
              expect( g.keys ).to eq [1, 2, 3, 4, 5]
            end

            it ' => :desc sorts in reverse order' do
              options[:sort] = {:keys => :desc}
              expect( g.keys ).to eq [5, 4, 3, 2, 1]
            end
          end


          describe ':count' do
            describe 'as standalone key' do
              it 'sorts by :count ascendingly, then :keys ascendingly' do
                options[:sort] = :count
                expect(g).to eq  ({2=>1, 5=>1, 1=>2, 3=>2, 4=>3})
              end
            end

            describe 'as Hash' do
              it 'can specify :desc order' do
                options[:sort] = {:count => :desc}
                expect(g.keys).to eq  [4, 1, 3, 2, 5]
              end

              it 'can specify :keys => :desc' do
                options[:sort] = {:count => :desc, :keys => :desc}
                expect(g.keys).to eq  [4, 3, 1, 5, 2]
              end

              it 'lets :count always take precedence' do
                options[:sort] = {:count => :asc, :keys => :desc}
                expect(g.keys).to eq  [5, 2, 3, 1, 4]
              end

            end
          end





          context '(Proc) =>' do
            it 'sorts by proc.call(k, v)' do
              expect( gcount(collection, :sort => ->(k, v){ [-v, -k] }).keys ).to eq [4, 3, 1, 5, 2]
            end

            it 'sorts by key, secondarily' do
              expect( gcount(collection, :sort => ->(k, v){ "CONSTANT" }).keys ).to eq [1, 2, 3, 4, 5]
            end

            it 'raises ArgumentError unless arity is 2' do
              expect{ gcount(collection, sort: ->(k){ k } ) }.to raise_error ArgumentError
            end
          end

          context 'false / :false' do
            it 'does no sorting' do
              expect( gcount(collection, :sort => false).keys ).to eq [3, 2, 4, 5, 1]
            end
          end

          context 'true / :true' do
            it 'sorts by ascending :keys (i.e. default)' do
              expect( gcount(collection, :sort => true).keys ).to eq gcount(collection, :sort => :keys).keys
            end
          end

          context "non-specified object type => " do
            it 'raises an ArgumentError' do
              expect{ gcount(collection, sort: 'keys')}.to raise_error ArgumentError
            end
          end

          context 'invalid key =>' do
            it 'raises an Argument Error' do
              expect{ gcount(collection, sort: :key)}.to raise_error ArgumentError
            end
          end
        end
      end # sort


      # describe ':order =>' do
      #   let(:collection){ [2, 1, 1, 3] }

      #   context ':asc =>' do
      #     it 'orders ascendingly, i.e. does not change result of sorting op' do
      #       expect( gcount(collection, :order => :asc ).keys).to eq [1, 2, 3]
      #     end
      #   end

      #   context ':desc / :reverse =>' do
      #     it 'reverses sort opt order' do
      #       expect( gcount(collection, :order => :desc ).keys).to eq [3, 2, 1]
      #       expect( gcount(collection, :order => :reverse ).keys).to eq [3, 2, 1]
      #     end
      #   end

      #   context 'something else =>' do
      #     it 'raises ArgumentError' do
      #       expect{ gcount(collection, order: :whatev )}.to raise_error ArgumentError
      #     end
      #   end
      # end # :order

      describe ':as =>' do
        let(:collection){ [2, 1, 1, 3] }

        describe 'nil =>' do
          it 'returns a Hash' do
            expect(gcount(collection, as: nil )).to eq ({1 => 2, 2 => 1, 3 => 1})
          end
        end

        describe 'Hash / :hash =>' do
          it 'returns a Hash' do
            expect(gcount(collection, as: Hash )).to eq ({1 => 2, 2 => 1, 3 => 1})
            expect(gcount(collection, as: :hash )).to eq ({1 => 2, 2 => 1, 3 => 1})
          end
        end
        describe 'Array / :array => ' do
          it 'returns an Array' do
            expect(gcount(collection, as: :array )).to eq Array({1 => 2, 2 => 1, 3 => 1})
            expect(gcount(collection, as: :Array )).to eq Array({1 => 2, 2 => 1, 3 => 1})
          end
        end
      end # :as


      describe ':count => false ' do
        # when we want #group_by, but with :sort, :order, and :as conveniences
        # This affects the returned collection BEFORE :sort, :order, and :as
        let(:collection){ [3, 2, 1, 1] }

        context 'with blank options' do
          context 'no block' do
            let(:g){ gcount( collection, count: false ) }
            it 'does not act EXACTLY like #group_by sans &a_block' do
              expect( g ).to_not eq collection.group_by
            end

            it 'returns a Hash' do
              expect( g ).to be_a Hash
            end

            it 'sorts by :keys ascending as a default' do
              expect(g.keys).to eq [1, 2, 3]
            end


            it 'keeps values as groups of members' do
              expect( g.values.all?{|a| a.is_a?Array} ).to be_true
            end
          end
        end
        context 'with other options' do
          context ':as =>' do
            let(:opts){ ( {count: false} )}
            let(:g){ gcount( collection, opts) }


            describe 'Hash/:hash => ' do
              it 'is a Hash' do
                opts[:as] = :hash
                expect( g.values ).to eq [[1, 1], [2], [3]]
              end
            end

            describe 'Array/:array > ' do
              it 'is an Array' do
                opts[:as] = Array
                expect( g ).to eq [[1, [1, 1]], [2, [2]], [3, [3]]]
              end
            end
          end


          context ':sort =>' do
            let(:opts){ (  {count: false} )}
            let(:g){ gcount( collection, opts) }

            describe ':keys' do
              it 'sorts by key as expected' do
                opts[:sort] = :keys

                expect(g.keys).to eq [1, 2, 3]
              end
            end

            describe 'Proc =>' do
              it 'sorts by evaluation of Proc as expected' do
                opts[:sort] = ->(k, v){ -v.size }
                expect(g.keys).to eq [1, 2, 3]
              end
            end

            describe ':count =>' do
              it 'sorts by count of grouped collection' do
                coll_ordered_by_size = gcount( collection, count: false, :sort => ->(k, v){ v.size} )
                opts[:sort] = :count

                expect(g).to eq coll_ordered_by_size
              end
            end
          end


        end
      end # count => false







    end # are set
  end # options
end


