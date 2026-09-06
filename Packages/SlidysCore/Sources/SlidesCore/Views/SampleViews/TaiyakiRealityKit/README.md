# Procedural Taiyaki

This sample generates every mesh and texture in Swift and displays them using
RealityKit. It does not load the reference PNG, a model, a Reality Composer scene,
or a material/shader asset. The existing Blender sample is independent.

## Reference analysis before implementation

Coordinates: head left, tail right, Y up, decorated/cut side toward +Z. The original
upright icon is interpreted after rotating it into this common orientation. All
measurements are visual estimates, not measurements of the Blender geometry.

| Feature | Interpretation of all five supplied images |
| --- | --- |
| Front silhouette | Large rounded forehead, low projecting lip, full belly, narrow tail root; total length approximately 1.5 times the height including fins. |
| Maximum width/length | Nose to tail tip. Body excluding tail approximately 75–80% of total length. |
| Maximum height | Dorsal tip to small ventral fin. The body itself occupies approximately 75% of this height. |
| Maximum thickness | Oblique images 3 and 4 imply a shallow baked shell, approximately 12–17% of total length, not a spherical fish. |
| Head volume | The head occupies roughly the left half of the fish and stays fuller than the rear body. |
| Central bulge | The broad sides are convex; thickness should vary smoothly across the forehead and lower belly. |
| Taper | Thickness decreases toward the narrow tail root and reaches a rounded, thin perimeter. |
| Tail | Broad fan, round outer tips and a shallow central notch; small curvature through depth. |
| Fins | Dorsal rises backward from the forehead into a rounded triangular fin; smaller ventral fin slopes backward below the belly. Both belong to the same flattened baking mold. |
| Opening | Image 1 and the original icon show a tall broken cross-section in the middle, behind the face. The nose retains its separate mouth-shaped mold line. Preserve this distinctive design rather than relocating the filling to the nose. |
| Filling | Many overlapping reddish-brown oval beans, contained by a pale crumb wall; modest protrusion beyond the front, clearly visible in image 3. |
| Eye | Small round brown eye below a thick diagonal eyelid, high on the forehead. It is a mold mark with shallow relief. |
| Mold marks | Broad cheek arc, three gill strokes, sparse scalloped scale columns, outer rear arc, three tail rays, and short fin ribs. |
| Logo | Dark handwritten “Sugiy” on the lower rear side, below the cut. |
| Front/back relation | Image 2 is the opposite broad side: mirrored silhouette and matching marks, with continuous pastry covering the filling. |
| Oblique relation | Images 3 and 4 show continuous rounded sidewalls, thinner fins, and a cut that opens on only one broad face. |
| Color | Prioritize the original icon's soft ochre/golden brown over the Blender screenshots' more strongly mottled surface. |

## Construction and tradeoffs

- `TaiyakiConfiguration.swift`: normalized proportions, bounded configuration and
  shared artistic landmarks. Only `bodyLength` is in meters.
- `Geometry/TaiyakiMesh.swift`: mesh buffers, area-weighted vertex normals,
  Catmull–Rom interpolation, ray/contour intersection, deterministic random source.
- `Geometry/BodyMeshBuilder.swift`: sampled 2D contour, continuous head/belly/tail
  thickness field, front annulus around a real opening, uninterrupted back, and
  shared perimeter vertices. Cosine-spaced rings resolve the rounded edge.
- `Geometry/TailMeshBuilder.swift`, `Geometry/FinMeshBuilder.swift`: closed curved
  lenses with custom fan/fin contours and thin edges. Roots overlap inside the body.
- `Geometry/MouthMeshBuilder.swift`: scalloped superellipse, beveled cream-colored
  crumb wall and recessed filling well. It shares its exact outer boundary with
  the hole in the front shell.
- `Filling/FillingBuilder.swift`: seeded oval bean meshes with individual position,
  orientation, size, brightness and slight asymmetry. Combined into four palette
  meshes rather than one entity per bean.
- `Surface/SurfacePatternBuilder.swift`: shallow flattened strokes individually
  projected onto the same surface evaluators, including the handwritten logo.
- `Materials/TaiyakiMaterialFactory.swift`: in-memory procedural color and normal
  maps plus rough, nonmetallic PBR materials; no imported image texture.
- `TaiyakiEntity.swift`: background CPU generation and a single RealityKit upload,
  organized under `TaiyakiEntity` with the named body/fin/eye/mouth/filling/pattern/logo parts.
- `TaiyakiRealityKitSampleView.swift`: virtual camera, balanced lights, drag/pinch,
  front/oblique/side/back inspection presets, reset and measured mesh statistics.
- `../SamplePageView.swift`: one new `SamplePageType.taiyakiRealityKit` entry, using
  the existing list selection and platform-specific presentation.

### Surface method selection

| Method | Decision |
| --- | --- |
| Thin/embossed geometry | Chosen for a small number of broad molded lines; remains legible obliquely and merges into one mesh. |
| Recessed geometry | Used for the filling opening and its walls. Full boolean engraving is unnecessary for the graphic mold lines. |
| Decals/generated textures | Chosen for fine grain and baked color; avoids thousands of tiny polygons. |
| Procedural textures | Generated once as pixels in Swift, then uploaded as RealityKit textures with mipmaps. |
| ShaderGraphMaterial | Unnecessary asset graph/complexity for a static sample. |
| CustomMaterial/LowLevelMesh | No per-frame deformation is needed. MeshDescriptor plus PBR is simpler and also works across the package's platforms. |
| 3D text | Replaced with surface-projected handwritten strokes to retain the logo's gesture and avoid floating flat text. |

## Performance and limitations

The UI reports the actual triangle and model counts. Generation happens once per
presentation; gestures only update a parent transform. There is one input collision
box, four bean material groups, and no per-frame CPU geometry work. The two 512²
RGBA maps occupy approximately 2.7 MiB including mipmaps before GPU-specific overhead.
The model count is not a measured GPU draw-call count.

60 fps is the target, not a claim based on Simulator timing. Confirm frame time,
thermal behavior and GPU counters on a physical iPhone. If needed, lower
`contourSegments`, `bodyRings` and `textureResolution` first.

The main differences from an authored Blender asset are the simpler pore structure,
uniform shallow relief instead of fully sculpted mold grooves, approximate logo
lettering, and simplified torn crumb microgeometry. Better matching these would
require richer procedural surface fields and local mesh refinement, not importing
the Blender model.
