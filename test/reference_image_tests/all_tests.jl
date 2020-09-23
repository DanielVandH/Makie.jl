using AbstractPlotting: @cell, save_result
using MeshIO
using AbstractPlotting

module RNG

using StableRNGs
using Colors
using Random

const STABLE_RNG = StableRNG(123)

rand(args...) = Base.rand(STABLE_RNG, args...)
randn(args...) = Base.randn(STABLE_RNG, args...)

seed_rng!() = Random.seed!(STABLE_RNG, 123)

function Base.rand(r::StableRNGs.LehmerRNG, ::Random.SamplerType{T}) where T <: ColorAlpha
    return T(Base.rand(r), Base.rand(r), Base.rand(r), Base.rand(r))
end

function Base.rand(r::StableRNGs.LehmerRNG, ::Random.SamplerType{T}) where T <: AbstractRGB
    return T(Base.rand(r), Base.rand(r), Base.rand(r))
end

end

using .RNG

using AbstractPlotting: Record, Stepper

module MakieGallery
    using FileIO
    assetpath(files...) = normpath(joinpath(@__DIR__, "..", "..", "..", "MakieGallery", "assets", files...))
    loadasset(files...) = FileIO.load(assetpath(files...))
end
using .MakieGallery

function load_database()
    empty!(AbstractPlotting.DATABASE)
    empty!(AbstractPlotting.UNIQUE_DATABASE_NAMES)
    include("examples2d.jl")
    include("attributes.jl")
    include("documentation.jl")
    include("examples2d.jl")
    include("examples3d.jl")
    include("layouting.jl")
    include("short_tests.jl")
    return AbstractPlotting.DATABASE
end

db = load_database()

recording_dir = joinpath(@__DIR__, "test_output")
rm(recording_dir, recursive=true, force=true); mkdir(recording_dir)

function run_tests()
    evaled = 1
    AbstractPlotting.inline!(true)
    for (name, func) in db
        save_result(joinpath(recording_dir, name), func())
        evaled += 1
    end
    return evaled
end

run_tests()
