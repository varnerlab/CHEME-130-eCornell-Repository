# setup paths -
const _ROOT = @__DIR__

# check: do we need to download any packages?
using Pkg
if (isfile(joinpath(_ROOT, "Manifest.toml")) == false) # have manifest file, we are good. Otherwise, we need to instantiate the environment
    Pkg.activate("."); Pkg.resolve(); Pkg.instantiate(); Pkg.update();
end

# load the required packages -
using Distributions
using Plots
using Colors
using LinearAlgebra
using Statistics